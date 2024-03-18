import os
import argparse
import os

def check_log_files(directory):
    succesful_string = "fMRIPrep finished successfully!"

    summary = []
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        if os.path.isfile(file_path) and file_path.endswith('.out'):
            with open(file_path, 'r') as file:
                sub_ID = file.readline().strip()
                if succesful_string in file.read():
                    out_status = 1
                else:
                    out_status = 0
        summary.append({'log_file': filename.strip('.out'), 'sub': sub_ID, 'status': out_status})
        
    summary = sorted(summary, key=lambda d: d['sub'])
    return summary

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Check if files in a directory contain a specific string')
    parser.add_argument('-d','--logs-dir', type=str, help='Path to the directory of logs')
    parser.add_argument('-f','--out-file', type=str, help='output file')
    args = parser.parse_args()
    log_dir = args.logs_dir
    outfile = args.out_file

    summary = check_log_files(log_dir)
    success_count = sum(1 for v in summary if v['status']==1)
    fail_count = len(summary) - success_count

    with open(outfile, 'w') as f:
        for d in summary:
            f.write(f"{d.get('sub')}\t{d.get('status')}\t{d.get('log_file')}\n")
        f.write('-------------\n')
        f.write(f'Success\t{success_count}\n')
        f.write(f'Fails\t{fail_count}\n')
        f.write('-------------\n')
        f.write(f'Total\t{len(summary)}\n')
    print('Done')
