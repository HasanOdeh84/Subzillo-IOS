import os
import json

base_path = "Subzillo/Resources/Assets.xcassets/NewColors"

def create_color_asset(name, colors_config):
    asset_path = os.path.join(base_path, f"{name}.colorset")
    os.makedirs(asset_path, exist_ok=True)
    
    contents = {
        "colors": [],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    for config in colors_config:
        hex_code = config['hex'].lstrip('#')
        r = int(hex_code[0:2], 16) / 255.0
        g = int(hex_code[2:4], 16) / 255.0
        b = int(hex_code[4:6], 16) / 255.0
        alpha = config.get('alpha', 1.0)
        
        color_entry = {
            "color": {
                "color-space": "srgb",
                "components": {
                    "alpha": f"{alpha:.3f}",
                    "blue": f"{b:.3f}",
                    "green": f"{g:.3f}",
                    "red": f"{r:.3f}"
                }
            },
            "idiom": "universal"
        }
        
        if 'appearance' in config:
            color_entry["appearances"] = [
                {
                    "appearance": "luminosity",
                    "value": config['appearance']
                }
            ]
            
        contents["colors"].append(color_entry)
        
    with open(os.path.join(asset_path, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)

# Raw Colors Data
raw_colors = [
    ("BrandFrom_Dark_A719DD", "#A719DD"),
    ("BrandMid_Dark_7C5CFF", "#7C5CFF"),
    ("BrandTo_Dark_4489EB", "#4489EB"),
    ("BrandGlow_Dark_A719DD", "#A719DD", 0.55),
    ("BGPrimary_Dark_0A0612", "#0A0612"),
    ("BGSecondary_Dark_120A1F", "#120A1F"),
    ("Surface_Dark_0A0612", "#0A0612"),
    ("SurfaceHi_Dark_1A1030", "#1A1030"),
    ("BGPrimary_Light_F7F7F9", "#F7F7F9"),
    ("Surface_Light_FFFFFF", "#FFFFFF"),
    ("SurfaceHi_Light_F1F2F7", "#F1F2F7"),
    ("TextPrimary_Dark_F4F1FB", "#F4F1FB"),
    ("TextDim_Dark_A8A4C0", "#A8A4C0"),
    ("TextFaint_Dark_7A7698", "#7A7698"),
    ("TextPrimary_Light_0E101A", "#0E101A"),
    ("TextDim_Light_60637A", "#60637A"),
    ("Danger_Dark_FF5A7A", "#FF5A7A"),
    ("Danger_Light_E43C5C", "#E43C5C"),
    ("Success_Dark_5CE4A8", "#5CE4A8"),
    ("Success_Light_0EA870", "#0EA870"),
    ("Warning_Any_FFCB5C", "#FFCB5C")
]

# Combined Colors Data
combined_colors = [
    ("BrandFrom", [{"hex": "#A719DD"}]),
    ("BrandMid", [{"hex": "#7C5CFF"}]),
    ("BrandTo", [{"hex": "#4489EB"}]),
    ("BrandGlow", [{"hex": "#A719DD", "alpha": 0.55}]),
    ("BGPrimary", [{"hex": "#F7F7F9"}, {"hex": "#0A0612", "appearance": "dark"}]),
    ("BGSecondary", [{"hex": "#120A1F"}]), # Only dark provided, using as any
    ("Surface", [{"hex": "#FFFFFF"}, {"hex": "#0A0612", "appearance": "dark"}]),
    ("SurfaceHi", [{"hex": "#F1F2F7"}, {"hex": "#1A1030", "appearance": "dark"}]),
    ("TextPrimary", [{"hex": "#0E101A"}, {"hex": "#F4F1FB", "appearance": "dark"}]),
    ("TextDim", [{"hex": "#60637A"}, {"hex": "#A8A4C0", "appearance": "dark"}]),
    ("TextFaint", [{"hex": "#7A7698"}]), # Only dark provided
    ("Danger", [{"hex": "#E43C5C"}, {"hex": "#FF5A7A", "appearance": "dark"}]),
    ("Success", [{"hex": "#0EA870"}, {"hex": "#5CE4A8", "appearance": "dark"}]),
    ("Warning", [{"hex": "#FFCB5C"}])
]

# Create Raw Assets
for color in raw_colors:
    name = color[0]
    hex_code = color[1]
    alpha = color[2] if len(color) > 2 else 1.0
    create_color_asset(name, [{"hex": hex_code, "alpha": alpha}])

# Create Combined Assets
for name, configs in combined_colors:
    create_color_asset(name, configs)

print("Color assets created successfully!")
