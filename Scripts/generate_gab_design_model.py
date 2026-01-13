import json
import urllib.request
import re
import os

URL = "https://raw.githubusercontent.com/sanggab/DesignTokens/main/tokens.json"
OUTPUT_DIR = "../DesignTokensSystem"
OUTPUT_FILE = "GabDesignModel.swift"

def to_camel_case(text):
    parts = re.split(r'[^a-zA-Z0-9]', text)
    if not parts: return text.lower()
    
    first = parts[0].lower()
    rest = [p.capitalize() for p in parts[1:]]
    result = first + "".join(rest)
    
    if result and result[0].isdigit():
        return "n" + result
    return result

def to_pascal_case(text):
    parts = re.split(r'[^a-zA-Z0-9]', text)
    return "".join(p.capitalize() for p in parts)

def parse_color(color_str):
    color_str = color_str.strip().lower()
    
    if color_str.startswith("#"):
        hex_val = color_str.lstrip("#")
        if len(hex_val) == 3:
            r = int(hex_val[0]*2, 16) / 255.0
            g = int(hex_val[1]*2, 16) / 255.0
            b = int(hex_val[2]*2, 16) / 255.0
            a = 1.0
        elif len(hex_val) == 6:
            r = int(hex_val[0:2], 16) / 255.0
            g = int(hex_val[2:4], 16) / 255.0
            b = int(hex_val[4:6], 16) / 255.0
            a = 1.0
        elif len(hex_val) == 8:
            r = int(hex_val[0:2], 16) / 255.0
            g = int(hex_val[2:4], 16) / 255.0
            b = int(hex_val[4:6], 16) / 255.0
            a = int(hex_val[6:8], 16) / 255.0
        else:
            return None
        return (r, g, b, a)
    
    if color_str.startswith("rgb"):
        match = re.search(r'rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([0-9.]+))?\)', color_str)
        if match:
            r = int(match.group(1)) / 255.0
            g = int(match.group(2)) / 255.0
            b = int(match.group(3)) / 255.0
            a_str = match.group(4)
            a = float(a_str) if a_str else 1.0
            return (r, g, b, a)
            
    return None

def resolve_references(value, full_data):
    if isinstance(value, str):
        if value.startswith("{") and value.endswith("}"):
            ref_key = value[1:-1]
            ref_path = ref_key.split(".")
            
            # 1. Try resolving using the original tree-walking logic
            try:
                current = full_data
                for key in ref_path:
                    current = current[key]
                
                if isinstance(current, dict) and "value" in current:
                    return resolve_references(current["value"], full_data)
                elif isinstance(current, (str, int, float)):
                    return resolve_references(current, full_data)
            except (KeyError, TypeError):
                pass
            
            # 2. Root-relative lookup
            for root_key in full_data.keys():
                if not isinstance(full_data[root_key], dict): continue
                try:
                    current = full_data[root_key]
                    valid_path = True
                    for key in ref_path:
                        if key in current:
                            current = current[key]
                        else:
                            valid_path = False
                            break
                    if valid_path:
                        if isinstance(current, dict) and "value" in current:
                            return resolve_references(current["value"], full_data)
                        elif isinstance(current, (str, int, float)):
                            return resolve_references(current, full_data)
                except (KeyError, TypeError):
                    continue
            
            # 3. Flattened search (Fuzzy / Suffix Match)
            def flatten_data(node, prefix=""):
                flat = {}
                for k, v in node.items():
                    if k.lower() in ["metadata", "$metadata", "colorloader"]: continue
                    curr_path = f"{prefix}.{k}" if prefix else k
                    
                    if isinstance(v, dict):
                        if "value" in v:
                            flat[curr_path] = v["value"]
                        else:
                            flat.update(flatten_data(v, curr_path))
                return flat

            flat_map = flatten_data(full_data)
            for path, val in flat_map.items():
                if path.endswith("." + ref_key) or path == ref_key:
                    return resolve_references(val, full_data)

            return value
        return value
    
    if isinstance(value, dict):
        new_dict = {}
        for k, v in value.items():
            new_dict[k] = resolve_references(v, full_data)
        return new_dict
        
    return value

def generate_leaf(name, value, token_type, indent, full_path=""):
    lines = []
    
    if token_type == "color":
        rgba = parse_color(value)
        
        lookup_key = full_path if full_path else name

        if rgba:
            r, g, b, a = rgba
            hex_val = "#{:02X}{:02X}{:02X}{:02X}".format(int(a*255), int(r*255), int(g*255), int(b*255))
            lines.append(f'{indent}static var {name}: UIColor {{')
            lines.append(f'{indent}    let hex = ColorLoader.shared.getColorHex(named: "{lookup_key}") ?? "{hex_val}"')
            lines.append(f'{indent}    return UIColor(hex: hex)')
            lines.append(f'{indent}}}')
            lines.append(f'{indent}static var {name}Color: Color {{ Color(uiColor: {name}) }}')
        else:
            lines.append(f'{indent}static let {name}Raw = "{value}"')
            
    elif token_type == "asset":
        lookup_key = full_path if full_path else name
        lines.append(f'{indent}static var {name}: String {{ ColorLoader.shared.getString(named: "{lookup_key}") ?? "{value}" }}')
        
    elif token_type in ["spacing", "borderRadius", "fontSizes", "paragraphSpacing", "dimension"]:
        lookup_key = full_path if full_path else name
        try:
            clean_val = str(value).replace("px", "")
            float_val = float(clean_val)
            lines.append(f'{indent}static var {name}: CGFloat {{ ColorLoader.shared.getCGFloat(named: "{lookup_key}") ?? {float_val} }}')
        except ValueError:
             lines.append(f'{indent}static var {name}: String {{ ColorLoader.shared.getString(named: "{lookup_key}") ?? "{value}" }}')
             
    elif token_type == "boxShadow":
        enum_name = name[0].upper() + name[1:]
        lookup_key = full_path if full_path else name
        
        lines.append(f'{indent}enum {enum_name} {{')
        
        if isinstance(value, dict):
            x = value.get("x", "0").replace("px", "")
            y = value.get("y", "0").replace("px", "")
            blur = value.get("blur", "0").replace("px", "")
            spread = value.get("spread", "0").replace("px", "")
            color_str = value.get("color", "#000000")
            
            def print_num(k, v):
                sub_key = f"{lookup_key}.{k}"
                try:
                    f = float(v)
                    return f'{indent}    static var {k}: CGFloat {{ ColorLoader.shared.getCGFloat(named: "{sub_key}") ?? {f} }}'
                except:
                    return f'{indent}    static var {k}: String {{ ColorLoader.shared.getString(named: "{sub_key}") ?? "{v}" }}'

            lines.append(print_num("x", x))
            lines.append(print_num("y", y))
            lines.append(print_num("blur", blur))
            lines.append(print_num("spread", spread))
            
            rgba = parse_color(color_str)
            sub_key_color = f"{lookup_key}.color"
            
            if rgba:
                r, g, b, a = rgba
                hex_val = "#{:02X}{:02X}{:02X}{:02X}".format(int(a*255), int(r*255), int(g*255), int(b*255))
                lines.append(f'{indent}    static var color: UIColor {{')
                lines.append(f'{indent}        let hex = ColorLoader.shared.getColorHex(named: "{sub_key_color}") ?? "{hex_val}"')
                lines.append(f'{indent}        return UIColor(hex: hex)')
                lines.append(f'{indent}    }}')
                lines.append(f'{indent}    static var colorColor: Color {{ Color(uiColor: color) }}')
                lines.append(f'{indent}    static var value: GabShadow {{ GabShadow(x: CGFloat(x), y: CGFloat(y), blur: CGFloat(blur), spread: CGFloat(spread), color: colorColor) }}')
            else:
                lines.append(f'{indent}    static var colorRaw: String {{ ColorLoader.shared.getString(named: "{sub_key_color}") ?? "{color_str}" }}')
        
        lines.append(f'{indent}}}')
            
    else:
        lookup_key = full_path if full_path else name
        lines.append(f'{indent}static var {name}: String {{ ColorLoader.shared.getString(named: "{lookup_key}") ?? "{value}" }}')
        
    return "\n".join(lines)

def generate_swift_code(data, full_data, indent_level=0, path_prefix=""):
    lines = []
    indent = "    " * indent_level
    
    sorted_keys = sorted(data.keys())
    
    for key in sorted_keys:
        if key.lower() in ["metadata", "$metadata", "colorloader"]:
            continue
            
        val = data[key]
        
        is_leaf = isinstance(val, dict) and "value" in val and "type" in val
        
        if is_leaf:
            raw_value = val["value"]
            token_type = val["type"]
            
            resolved_value = resolve_references(raw_value, full_data)
            
            var_name = to_camel_case(key)
            full_path = f"{path_prefix}.{key}" if path_prefix else key
            lines.append(generate_leaf(var_name, resolved_value, token_type, indent, full_path))
            
        elif isinstance(val, dict):
            enum_name = to_pascal_case(key)
            new_prefix = f"{path_prefix}.{key}" if path_prefix else key
            
            lines.append(f'{indent}enum {enum_name} {{')
            lines.append(generate_swift_code(val, full_data, indent_level + 1, new_prefix))
            lines.append(f'{indent}}}')
            
    return "\n".join(lines)

def main():
    print(f"Fetching tokens from {URL}...")
    try:
        with urllib.request.urlopen(URL) as response:
            raw_json = response.read().decode()
            data = json.loads(raw_json)
            
        print("Generating Swift code...")
        
        swift_content = """import Foundation
import UIKit
import SwiftUI

struct GabShadow {
    let x: CGFloat
    let y: CGFloat
    let blur: CGFloat
    let spread: CGFloat
    let color: Color
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

enum GabDesignModel {
"""
        swift_content += generate_swift_code(data, data, 1)
        swift_content += "\n}\n"
        
        script_dir = os.path.dirname(os.path.abspath(__file__))
        output_path = os.path.join(script_dir, OUTPUT_DIR, OUTPUT_FILE)
        
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(swift_content)
            
        print(f"Successfully created {output_path}")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
