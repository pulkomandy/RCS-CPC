/*
 * RCS (Reverse Computer Screen) by Einar Saukas
 *
 * http://www.worldofspectrum.org
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE  16384
#define LINE_OFFSET 0x800

unsigned char input_data[MAX_SIZE+1];
unsigned char output_data[MAX_SIZE];
size_t file_size;
size_t screen_width;

void convert(int decode_mode) {
    int sector;
    int row;
    int lin;
    int col;
    int i;

    lin = 0;
    col = 0;
    row = 0;

    /* transform bitmap area */
    for (i = 0; i < MAX_SIZE; i++) {
        if (decode_mode) {
            output_data[lin] = input_data[i];
        } else {
            output_data[i] = input_data[lin];
        }

        lin += LINE_OFFSET;
        if (lin >= MAX_SIZE) {
            col += screen_width;
            if (col >= LINE_OFFSET) {
                row++;
                col = row;
            }
            lin = col;
        }
    }
}

int main(int argc, char *argv[]) {
    int forced_mode = 0;
    int decode_mode = 0;
    char *input_name = NULL;
    char *output_name = NULL;
    FILE *ifp;
    FILE *ofp;
    size_t bytes_read;
    int i;

    printf("RCS: Reverse Computer Screen by Einar Saukas - CPC version by PulkoMandy\n");

    screen_width = 80;

    /* process command-line arguments */
    for (i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-f")) {
            forced_mode = 1;
        } else if (!strcmp(argv[i], "-d")) {
            decode_mode = 1;
        } else if (!strcmp(argv[i], "-w")) {
            screen_width = strtol(argv[++i], NULL, 0);
        } else if (input_name == NULL) {
            input_name = argv[i];
        } else if (output_name == NULL) {
            output_name = argv[i];
        } else {
            input_name = NULL;
            break;
        }
    }

    /* validate command-line arguments */
    if (input_name == NULL) {
         fprintf(stderr, "Usage: %s [-f] [-d] [-w n] input [output]\n"
                         "  -f      Force overwrite of output file\n"
                         "  -d      Decode from RCS to SCR\n"
                         "  -w n    Screen width is n bytes (default is 80)\n", argv[0]);
         exit(1);
    }
    if (output_name == NULL) {
        output_name = (char *)malloc(strlen(input_name)+5);
        strcpy(output_name, input_name);
        strcat(output_name, decode_mode ? ".scr" : ".rcs");
    }

    /* open input file */
    ifp = fopen(input_name, "rb");
    if (!ifp) {
         fprintf(stderr, "Error: Cannot access input file %s\n", input_name);
         exit(1);
    }

    /* read input file */
    file_size = 0;
    while ((bytes_read = fread(input_data+file_size, sizeof(char), MAX_SIZE+1-file_size, ifp)) > 0) {
        file_size += bytes_read;
    }

    /* close input file */
    fclose(ifp);

    /* generate output file */
    if (file_size > 0 && file_size <= MAX_SIZE) {
        convert(decode_mode);
    } else {
        fprintf(stderr, "Error: Invalid input file %s\n", input_name);
        exit(1);
    }

    /* check output file */
    if (!forced_mode && fopen(output_name, "rb") != NULL) {
         fprintf(stderr, "Error: Already existing output file %s\n", output_name);
         exit(1);
    }

    /* create output file */
    ofp = fopen(output_name, "wb");
    if (!ofp) {
         fprintf(stderr, "Error: Cannot create output file %s\n", output_name);
         exit(1);
    }

    /* write output file */
    if (fwrite(output_data, sizeof(char), MAX_SIZE, ofp) != MAX_SIZE) {
         fprintf(stderr, "Error: Cannot write output file %s\n", output_name);
         exit(1);
    }

    /* close output file */
    fclose(ofp);

    /* done! */
    printf("%scoded screen!\n", decode_mode ? "De" : "En");

    return 0;
}
