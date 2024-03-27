import os
import argparse
import os
import re

def check_log_files(logfiles):
    sub_pattern = r"subject: (sub-\d+)"
    status_pattern = r"Completed with return code: (\d+)"

    summary = []
    for logfile in logfiles:
        filename = os.path.basename(logfile)
        if os.path.isfile(logfile) and logfile.endswith('.out'):
            with open(logfile, 'r') as file:
                first_line = file.readline()
                match = re.search(sub_pattern, first_line)
                if match:
                    sub_ID = match.group(1)
                else:
                    sub_ID = "not found"
                for line in file:
                    # Use regular expression to search for the pattern
                    match = re.search(status_pattern, line)
                    # If match is found, extract the return code
                    if match:
                        return_code = int(match.group(1))
                    else:
                        return_code = -1
        else:
            print('File not Found!')
        summary.append({'log_file': filename.strip('.out'), 'sub': sub_ID, 'status': return_code})
        
    summary = sorted(summary, key=lambda d: d['sub'])
    return summary

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Create a summary of how fmriprep ran on multiple subjects')
    parser.add_argument('-d','--logs-dir', type=str, help='Path to the directory of logs')
    parser.add_argument('-f','--out-file', type=str, help='output file')
    parser.add_argument('-p','--process', type=str, default=False, help='type of process, bold or anat')
    args = parser.parse_args()
    log_dir = args.logs_dir
    outfile = args.out_file
    process = args.process

    logfiles = [os.path.join(log_dir,f) for f in os.listdir(log_dir) if f.endswith(".out")]
    # filter for specific part of workflow if specified
    if process:
        logfiles = filter(lambda s: process in s, logfiles)

    summary = check_log_files(logfiles)
    success_count = sum(1 for v in summary if v['status']==0)
    error_count = sum(1 for v in summary if v['status']==1)
    other_count = len(summary)-success_count-error_count

    with open(outfile, 'w') as f:
        f.write("subject\tstatus\tlog_file\n")
        for d in summary:
            f.write(f"{d.get('sub')}\t{d.get('status')}\t{d.get('log_file')}\n")
        f.write('-------------\n')
        f.write(f'Success\t{success_count}\n')
        f.write(f'Error\t{error_count}\n')
        f.write(f'Other\t{other_count}\n')
        f.write('-------------\n')
        f.write(f'Total\t{len(summary)}\n')
    print(f'Succes: {success_count}')
    print(f'Error: {error_count}')
    print(f'Running: {other_count}')

    print('>>>> Done')
