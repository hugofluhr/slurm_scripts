import argparse

def combine_summaries(file1, file2, output_file):
    # Read the first input file
    with open(file1, 'r') as f1:
        data1 = [line.strip().split('\t') for line in f1]

    # Read the second input file
    with open(file2, 'r') as f2:
        data2 = [line.strip().split('\t') for line in f2]

    # Find the common subIDs with status 0
    common_subids = set(row[0] for row in data1 if row[1] == '0') & set(row[0] for row in data2 if row[1] == '0')

    # Write the output file
    with open(output_file, 'w') as out:
        for subid in common_subids:
            out.write(subid + '\n')

if __name__ == '__main__':
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='Combine summaries')
    parser.add_argument('--f1', help='Path to the first input TSV file')
    parser.add_argument('--f2', help='Path to the second input TSV file')
    parser.add_argument('--out', help='Path to the output TSV file')
    args = parser.parse_args()

    # Call the combine_summaries function
    combine_summaries(args.f1, args.f2, args.out)