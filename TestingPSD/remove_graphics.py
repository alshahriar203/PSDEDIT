from PIL import Image
from psd_tools import PSDImage
import shutil
import os

def remove_graphics_layers(psd): #removes non-text layers from psd file
    for layer in psd._layers:
        remove_graphics(layer)


def remove_graphics(layer): #recursively makes non-text layers invisible, and text layers visible
    if layer.kind == 'group':
        for sub_layer in layer:
            remove_graphics(sub_layer)
    else:
        if layer.kind == 'type':
            layer.visible = True
            layer.opacity = 255
        else:
            layer.visible = False
    
        

def flatten_and_save(psd_path, output_path):
    # Load PSD file
    try:
        psd = PSDImage.open(psd_path)

        # Remove text layers
        remove_graphics_layers(psd)

        # Flatten all layers
        flattened_image = psd.composite(force="True")

        # Save as PNG or JPG
        flattened_image.save(output_path, format="PNG")
        
    except Exception as e:
        print(f"Error processing {psd_path}: {e}")
        shutil.copy(psd_path, os.path.join('GENERALERROR', os.path.basename(psd_path)))

        
    

if __name__ == "__main__":
    # Specify the input PSD file path
    psd_path = 'aqua.psd'

    # Specify the desired output file path and filename
    output_path = 'output.png'

    flatten_and_save(psd_path, output_path)
