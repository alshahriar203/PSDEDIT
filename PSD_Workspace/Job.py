import os
import time
from multiprocessing import Pool, Lock
from PIL import Image
from psd_tools import PSDImage
import csv
import signal
import shutil

lock=Lock()


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


def remove_text_layers(psd): #removes text layers from psd file
    for layer in psd._layers:
        remove_text(layer)


def remove_text(layer): #recursively makes text layers invisible, and non-text layers visible
    if layer.kind=='group':
        for sub_layer in layer:
            remove_text(sub_layer)
    else:
        if layer.kind == 'type':
            layer.visible = False
        else:
            layer.visible = True




def process_psd_dir(psd_files, log_file):
    logfile=open(log_file, mode='a', newline='')
    log_writer = csv.writer(logfile)

    print("length of psd files: ", len(psd_files))

    for psd_path in psd_files:
        print("processing: "+psd_path)
        try:
            psd = PSDImage.open(psd_path)
    
            # Check if dimensions are square
            #if psd.size[0] != psd.size[1]:
            #    return

            start_time = time.perf_counter()

            # Create the output filenames
            output_txtonly_path = os.path.join('TXTONLY', os.path.basename(psd_path).replace('.psd', '.png'))
            output_graphicsonly_path = os.path.join('GRAPHICSONLY', os.path.basename(psd_path).replace('.psd', '.png'))

            # Remove graphics layers
            remove_graphics_layers(psd)
       
            try:
                # Save PNG with only text layers
                psd.composite(force=True).save(output_txtonly_path, format="PNG")
            except Exception as e:
                print(f"Error processing {psd_path} for text layers: {e}")
                shutil.copy(psd_path, os.path.join('TXTLAYERERROR', os.path.basename(psd_path)))


            # Remove text layers
            remove_text_layers(psd)
        
            try:
                # Save PNG with only graphics layers
                psd.composite(force=True).save(output_graphicsonly_path, format="PNG")
            except Exception as e:
                print(f"Error processing {psd_path} for graphics layers: {e}")
                shutil.copy(psd_path, os.path.join('GRAPHICSLAYERERROR', os.path.basename(psd_path)))

            
            #critical section
            try:
                lock.acquire()
                print('write')
                finish_time = time.perf_counter()
                time_taken = finish_time - start_time
                print([os.path.basename(psd_path), os.path.getsize(psd_path), start_time, finish_time, time_taken])
                log_writer.writerow([os.path.basename(psd_path), os.path.getsize(psd_path), start_time, finish_time, time_taken])
            except Exception as e:
                print(f"Error writing to log: {e}")
            finally:
                lock.release() 
                print("lock release")

        except Exception as e:
            print(f"Error processing {psd_path}: {e}")
            shutil.copy(psd_path, os.path.join('GENERALERROR', os.path.basename(psd_path)))

        # Delete PSD file after processing
        os.remove(psd_path)



if __name__ == "__main__":
    # Specify the directory containing PSD files
    psd_directory = 'PSD'
    
    # Specify the directories to save the outputs
    log_file = 'processing_log.csv'

    # Process PSD files in the directory
    psd_files = [os.path.join(psd_directory, filename) for filename in os.listdir(psd_directory) if filename.endswith(".psd")]
    
    # Use multiprocessing pool to process PSD files in parallel
    with Pool() as pool:
        pool_size=pool._processes
        chunk_size=int(len(psd_files)/pool_size)

        print(pool_size)
        print(chunk_size)
        
        if chunk_size<1:
            chunk_size=1

        psd_files_chunks=[]
        for i in range(pool_size-1):
            psd_files_chunks.append(psd_files[chunk_size*i:chunk_size*(i+1)])
            
        psd_files_chunks.append(psd_files[chunk_size*(pool_size-1):])

        #logfile=open(log_file, mode='a', newline='')
        #log_writer = csv.writer(logfile)
        #print('write')
        #log_writer.writerow(['PSD Filename', 'Size of File', 'Start Time', 'End Time', 'Time Take'])

        # Create output directories if they don't exist
        os.makedirs('TXTONLY', exist_ok=True)
        os.makedirs('GRAPHICSONLY', exist_ok=True)
        os.makedirs('TXTLAYERERROR', exist_ok=True)
        os.makedirs('GRAPHICSLAYERERROR', exist_ok=True)
        os.makedirs('GENERALERROR', exist_ok=True)

        pool.starmap(process_psd_dir, [(psd_files, log_file) for psd_files in psd_files_chunks])
        
    signal.pause()

    
