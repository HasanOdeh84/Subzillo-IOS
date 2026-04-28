/**
 * AgentScripts.js 
 * Core interaction and extraction logic for the Subzillo Browser Automation Agent.
 * Ported from Android implementation.
 */

window.SubzilloAgent = {
    
    // 1. Wait for page stability
    isContentReady: function() {
        var body = document.body;
        if (!body) return false;
        var textLength = body.innerText.trim().length;
        var hasElements = body.querySelectorAll('a, button, [role="button"], input').length > 0;
        return textLength > 40 || hasElements;
    },

    // 2. Extract DOM Snapshot
    extractSnapshot: function() {
        function getText(doc) {
            if (!doc) return '';
            let text = '';
            function walk(node) {
                if (node.nodeType === Node.TEXT_NODE) {
                    text += node.textContent + ' ';
                } else if (node.nodeType === Node.ELEMENT_NODE) {
                    var tag = node.tagName.toUpperCase();
                    if (['SCRIPT', 'STYLE', 'HEAD', 'NOSCRIPT', 'META', 'LINK'].includes(tag)) return;
                    var style = window.getComputedStyle(node);
                    if (style.display === 'none' || style.visibility === 'hidden') return;
                    if (tag === 'IFRAME') {
                        try { if (node.contentDocument) walk(node.contentDocument); } catch(e) {}
                    } else {
                        for (var i = 0; i < node.childNodes.length; i++) walk(node.childNodes[i]);
                        if (node.shadowRoot) walk(node.shadowRoot);
                    }
                } else if (node.nodeType === Node.DOCUMENT_NODE || node.nodeType === Node.DOCUMENT_FRAGMENT_NODE) {
                    var root = node.body || node;
                    for (var i = 0; i < root.childNodes.length; i++) walk(root.childNodes[i]);
                }
            }
            walk(doc);
            return text.trim().replace(/\s+/g, ' ');
        }

        var elements = [];
        var seen = new Set();
        function collect(root) {
            if (!root) return;
            var els = root.querySelectorAll('a, button, input, [role="button"], svg, i, [aria-label], [title], iframe, div, span');
            for(var i=0; i<els.length; i++) {
                var el = els[i];
                var tagName = el.tagName.toLowerCase();
                if (tagName === 'iframe') {
                    var label = el.getAttribute('aria-label') || el.getAttribute('title') || 'Iframe';
                    elements.push({ text: '[' + label + ']', href: '', selector: 'iframe' + (el.id ? '#'+el.id : '') });
                    try { if (el.contentDocument) collect(el.contentDocument); } catch(e) {}
                    continue;
                }
                var rect = el.getBoundingClientRect();
                if(rect.width === 0 || rect.height === 0) continue;
                var ariaLabel = el.getAttribute('aria-label');
                var title = el.getAttribute('title');
                var text = (el.innerText || el.value || ariaLabel || title || '').trim();
                var isIcon = tagName === 'svg' || tagName === 'i' || (el.className && el.className.toString().includes('icon'));
                var isInteractive = tagName === 'a' || tagName === 'button' || tagName === 'input' || el.getAttribute('role') === 'button' || el.onclick;
                if (['div', 'span'].includes(tagName) && !isInteractive && !ariaLabel && !title) {
                    if (!text || text.length > 60) continue;
                    if (el.children.length > 0 && el.innerText === el.children[0].innerText) continue;
                }
                if(!isInteractive && !isIcon && !text) continue;
                if (text.length > 50) text = text.substring(0, 50);
                var selector = tagName;
                if (el.id) selector += '#' + CSS.escape(el.id);
                else if (tagName === 'a' && el.getAttribute('href')) {
                    var href = el.getAttribute('href');
                    selector += '[href="' + href.replace(/"/g, '\\"') + '"]';
                }
                else if (ariaLabel) selector += '[aria-label="' + ariaLabel.replace(/"/g, '\\"') + '"]';
                else if (el.className && typeof el.className === 'string') {
                    var cls = el.className.split(/\s+/).filter(c => c).slice(0, 3).map(c => CSS.escape(c)).join('.');
                    if (cls) selector += '.' + cls;
                }
                if (selector.length > 200) selector = selector.substring(0, 200);
                if (seen.has(selector + text)) continue;
                seen.add(selector + text);
                elements.push({ 
                    text: text || ('['+tagName+']'), 
                    href: el.href || '', 
                    selector: selector,
                    x: Math.round(rect.left + rect.width / 2),
                    y: Math.round(rect.top + rect.height / 2)
                });
            }
            var all = root.querySelectorAll('*');
            for(var j=0; j<all.length; j++) { if(all[j].shadowRoot) collect(all[j].shadowRoot); }
        }

        var pageText = getText(document);
        collect(document);

        return {
            text: pageText,
            elements: elements.slice(0, 100),
            url: window.location.href,
            isLoggedIn: false,
            scrollY: window.scrollY
        };
    },

    // 3. Robust Clicking
    click: function(selector, clickText) {
        function find(root) {
            if (!root) return null;
            var lowText = (clickText || "").trim().toLowerCase();

            // 1. Selector Match
            if (selector) {
                try {
                    var el = root.querySelector(selector);
                    if (el) return el;
                } catch(e) {}
            }

            // 2. Fuzzy Text Match
            if (lowText) {
                var walker = document.createTreeWalker(root, NodeFilter.SHOW_ELEMENT, null, false);
                while(walker.nextNode()) {
                    var node = walker.currentNode;
                    var content = (node.innerText || "").trim().toLowerCase();
                    if (content.includes(lowText) && content.length < 100) return node;
                }
            }
            
            // 3. Deep Shadow Root Search
            var all = root.querySelectorAll('*');
            for(var i=0; i<all.length; i++) {
                if(all[i].shadowRoot) {
                    var found = find(all[i].shadowRoot);
                    if(found) return found;
                }
            }
            return null;
        }

        function findClickableParent(el) {
            while (el && el !== document.body) {
                var tag = el.tagName?.toLowerCase();
                var role = el.getAttribute?.('role');
                if (tag === 'button' || tag === 'a' || role === 'button' || el.onclick) return el;
                el = el.parentElement || el.host;
            }
            return null;
        }

        var el = find(document);
        if(!el) return "FAIL";
        
        var target = findClickableParent(el) || el;
        target.scrollIntoView({block: 'center', inline: 'center', behavior: 'instant'});

        // THE WARP: If it's a link, bypass clicking and just navigate
        if (target.tagName?.toLowerCase() === 'a' && target.href) {
            return "NAVIGATE:" + target.href;
        }

        // THE OVERLAY CHECK: See if something is blocking the button
        var rect = target.getBoundingClientRect();
        var x = rect.left + rect.width / 2;
        var y = rect.top + rect.height / 2;
        var elAtPoint = document.elementFromPoint(x, y);
        if (elAtPoint && elAtPoint !== target && !target.contains(elAtPoint)) {
            target = elAtPoint; // Click the blocker instead
        }

        // THE EVENT HAMMER (Mouse + Pointer + Touch)
        var types = ['mousedown', 'mouseup', 'click', 'pointerdown', 'pointerup', 'touchstart', 'touchend'];
        types.forEach(type => {
            try {
                var ev;
                if(type.startsWith('touch')) ev = new TouchEvent(type, {bubbles: true, cancelable: true, view: window, composed: true});
                else if(type.startsWith('pointer')) ev = new PointerEvent(type, {bubbles: true, cancelable: true, view: window, composed: true, isPrimary: true, pointerId: 1});
                else ev = new MouseEvent(type, {bubbles: true, cancelable: true, view: window, composed: true});
                target.dispatchEvent(ev);
            } catch(e) {}
        });
        
        if (typeof target.click === 'function') target.click(); 
        return "OK";
    },

    // 4. Typing
    type: function(selector, text) {
        try {
            var el = document.querySelector(selector);
            if(el) {
                el.value = text;
                el.dispatchEvent(new Event('input', { bubbles: true }));
                el.dispatchEvent(new Event('change', { bubbles: true }));
                return "OK";
            }
        } catch(e) {}
        return "FAIL";
    }
};
