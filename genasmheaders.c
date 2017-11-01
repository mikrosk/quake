/*
** genasmheaders.c
**
** Written by Frank Wille <frank@phoenix.owl.de>
**
** V0.1 (17.12.00)
**      created
*/

#define VERSION 0
#define REVISION 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define TMPFILE "./gendefs"
#define CMDBUFSIZE 1024
#define LINEBUFSIZE 128
#define INCPATHSIZE 256
#define ATTRNAMESIZE 64



main(int argc,char *argv[])
{
  int rc = 10;
  int fmt;
  FILE *fh,*fc;

  if (argc != 5) {
    printf("GenAsmHeaders V%d.%d - written by Frank Wille\n"
           "Usage:   %s <cmd file> <output file> <output fmt> <compiler>\n"
           "Example: %s ppcasm.cmd ppcdefs.i 1 \"vc -+ +ppc\"\n"
           "Output format 0 = EQU directives: symbol equ 10\n"
           "Output format 1 = .SET directives: .set symbol,10\n"
           "The compiler has to understand standard options like "
           "-I and -o.\n",
           VERSION,REVISION,argv[0],argv[0]);
    exit(1);
  }

  else {
    static char line[LINEBUFSIZE];
    static char incpath[INCPATHSIZE];
    static char cmdbuf[CMDBUFSIZE];
    static char structname[ATTRNAMESIZE];
    static char prefixname[ATTRNAMESIZE];
    int structmode = 0;

    incpath[0] = '\0';
    fmt = atoi(argv[3]);
    if (fmt>=2 || fmt<0) {
      printf("Output format %d is not supported!\n",fmt);
      exit(rc);
    }

    /* open, then read commands file */
    if (fh = fopen(argv[1],"r")) {

      if (fc = fopen(TMPFILE ".c","w")) {
        fprintf(fc,"#include <stdio.h>\n#include <stddef.h>\n"
                   "#include <stdlib.h>\n");

        while (fgets(line,LINEBUFSIZE-1,fh)) {
          char *p = line;

          while (*p && *p!='\n' && *p!='\r')
            p++;
          *p = '\0';
          if (line[0]=='#') {
            /* parse command */
            switch (toupper((unsigned char)line[1])) {
              case 'I':
                /* include path for specified header files */
                strncpy(incpath,&line[3],INCPATHSIZE-1);
                incpath[INCPATHSIZE-1] = '\0';
                break;
              case 'H':
                /* specify header file which is required for the */
                /* structures used in the commands file */
                if (!structmode)
                  fprintf(fc,"#include %s\n",&line[3]);
                else
                  printf("\"%s\"\nIgnored. Already in struct-mode.\n",
                         line);
                break;
              case 'S':
                /* set current structure name */
                if (!structmode) {
                  structmode = 1;
                  fprintf(fc,
                          "\nint esize(size_t s)\n"
                          "{\n"
                          "  int i;\n"
                          "  for (i=0; i<30; i++) {\n"
                          "    if (s == (1<<i))\n"
                          "      return i;\n"
                          "  }\n"
                          "  return -1;\n"
                          "}\n\n"
                          "main(void)\n"
                          "{\n"
                          "  FILE *fh;\n"
                          "  if (fh = fopen(\"%s\",\"w\")) {\n",
                          argv[2]);
                }
                prefixname[0] = '\0';
                sscanf(&line[3],"%s %s",structname,prefixname);
                if (prefixname[0])
                  strcat(prefixname,"_");
                break;
              case 'L':
                /* write size of current structure */
                if (structmode) {
                  switch (fmt) {
                    case 0:
                      fprintf(fc,"    fprintf(fh,\"%sSIZEOF\\tequ\\t"
                                 "%%lu\\n\",sizeof(%s));\n",
                              prefixname,structname);
                      break;
                    case 1:
                      fprintf(fc,"    fprintf(fh,\".set\\t%sSIZEOF,"
                                 "%%lu\\n\",sizeof(%s));\n",
                              prefixname,structname);
                      break;
                  }
                }
                else
                  printf("Can't write structure size yet!\n");
                break;
              case 'E':
                /* write base-2 exponential size of current structure */
                if (structmode) {
                  fprintf(fc,"    if (esize(sizeof(%s)) >= 0) {\n",
                          structname);
                  switch (fmt) {
                    case 0:
                      fprintf(fc,"      fprintf(fh,\"%sSIZEOF_EXP\\tequ\\t"
                                 "%%d\\n\",esize(sizeof(%s)));\n",
                              prefixname,structname);
                      break;
                    case 1:
                      fprintf(fc,"      fprintf(fh,\".set\\t%sSIZEOF_EXP,"
                                 "%%d\\n\",esize(sizeof(%s)));\n",
                              prefixname,structname);
                      break;
                  }
                  fprintf(fc,"    }\n"
                             "    else {\n"
                             "      printf(\"Size of %s can't be represented "
                             "by a base-2 exponent.\\n\");\n"
                             "      exit(20);\n"
                             "    }\n",structname);
                }
                else
                  printf("Can't write exponential size yet!\n");
                break;
            }
          }

          else {
            if (strlen(line) > 3) {
              if (structmode) {
                char cname[ATTRNAMESIZE],aname[ATTRNAMESIZE];

                /* write structure offset */
                sscanf(line,"%s %s",cname,aname);
                switch (fmt) {
                  case 0:
                    fprintf(fc,"    fprintf(fh,\"%s%s\\tequ\\t%%lu\\n\","
                               "offsetof(%s,%s));\n",
                            prefixname,aname,structname,cname);
                    break;
                  case 1:
                    fprintf(fc,"    fprintf(fh,\".set\\t%s%s,%%lu\\n\","
                               "offsetof(%s,%s));\n",
                            prefixname,aname,structname,cname);
                    break;
                }
              }
              else
                printf("\"%s\"\nIgnored. Missing at least one #h directive.\n",
                       line);
            }
          }
        }

        /* write rest of C source and close file */
        fprintf(fc,"    fclose(fh);\n"
                   "    exit(0);\n"
                   "  }\n"
                   "  exit(20);\n"
                   "}\n");
        fclose(fc);

        /* compile and execute assembler include generator */
        sprintf(cmdbuf,"%s %s%s -o " TMPFILE " " TMPFILE ".c",
                argv[4],incpath[0]?"-I":"",incpath);
        if (!system(cmdbuf)) {
          if (!system(TMPFILE)) {
            rc = 0;  /* ok, assembler include file created! */
          }
          else
            printf(TMPFILE " was unable to create include file %s\n",
                   argv[2]);
        }
        else
          printf("Could not compile: %s\n",cmdbuf);
      }
      else
        printf("Can't create " TMPFILE ".c!\n");

      fclose(fh);
    }
    else
      printf("Can't open commands file: %s\n",argv[1]);
  }
  exit(rc);
}
