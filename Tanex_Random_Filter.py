#!/usr/bin/env python3
# -*- coding: utf-8 -*-


#Program by Patrick Gagne
#patrick.gagne@canada.ca
#Natural Ressources Canada

import sys,os
import argparse
import math
import random
import pickle
import gzip
import datetime

class FastqSeq:
        def __init__(self, seqname, seq, sep, qual):
                self.seqname = seqname.strip("\n")[1:]
                self.seq = seq.strip("\n")
                self.sep = sep.strip("\n")
                self.qual = qual.strip("\n")
                #self.prob_qual=Qual_to_Prob(self.qual)
                #self.tran_qual=TranslateQual(self.qual)
        def __repr__(self):
                return repr((self.seqname, self.seq, self.qual))
        def fasta_write(self,file):
                file.write(">"+self.seqname+"\n")
                file.write(self.seq+"\n")
        def fastq_write(self,file):
            file.write(self.seqname+"\n")
            file.write(self.seq+"\n")
            file.write(self.sep+"\n")
            file.write(self.qual+"\n")

def TranslateQual(qualseq):
        phred_conv=[]
        for i in qualseq :
            phred_conv.append(ord(i)-33)
        return phred_conv

def Qual_to_Prob(qualstr):
    reslist=[]
    for i in qualstr:
        res=float((10**(float(-(ord(i)-33))/10)))
        reslist.append(res)
    return reslist


parser=argparse.ArgumentParser(description='Tanex Raw Fastq Quality Filtering and Random selection program')

parser.add_argument("-for", dest="fastq_forward", required=True, help=("Forward Fastq File (.fastq or .fastq.gz) [REQUIRED]"))
parser.add_argument("-rev", dest="fastq_reverse", required=True, help=("Reverse Fastq File (.fastq or .fastq.gz) [REQUIRED]"))
parser.add_argument("-nb", dest="nbseqs_int", required=True, help=("Number of sequence to select [REQUIRED]"))
parser.add_argument("-prefix", dest="out_prefix", required=True, help=("Fastq outfile prefix (final names will be PREFIX.for.fastq and PREFIX.rev.fastq) [REQUIRED]"))
parser.add_argument("-score", dest="score_int", default=25, help=("Minimum average quality score (See Phred Score Table for information)[Default = 25]"))
parser.add_argument("-report", dest="report_output", required=False, help=("Report output filename  [OPTIONAL]"))
parser.add_argument("-state", dest="random_statefile", required=False, help=("Random Module Internal State File (file will be created if not existing) [OPTIONAL]"))



#args=parser.parse_args('-for for.fastq.gz -rev rev.fastq.gz -prefix test -nb 200000 -score 35 -report report.txt'.split())
args=parser.parse_args()


nbseqs=int(args.nbseqs_int)
meanscore=int(args.score_int)

if args.random_statefile != None:
    try:
        f = open(str(args.random_statefile), 'rb')
        cur_state=pickle.load(f)
        print("State File Restored")
        f.close()
        random.setstate(cur_state)
    except IOError:
        cur_state=random.getstate()
        f = open(str(args.random_statefile), 'wb')
        pickle.dump(cur_state, f)
        print("New State File created")
        f.close()
        

print("Reading and filtering fastq files")
try :
    if str(args.fastq_forward).split(".")[-1] == "gz":
        fastqf=gzip.open(str(args.fastq_forward),'rt')
    else:
        fastqf=open(str(args.fastq_forward),'r')
except IOError:
    print("ERROR: Forward fastq '%s' not found or not accessible"%(str(args.fastq_forward)))
    sys.exit(1)

try :
    if str(args.fastq_reverse).split(".")[-1] == "gz":
        fastqr=gzip.open(str(args.fastq_reverse),'rt')
    else:
        fastqr=open(str(args.fastq_reverse),'r')
except IOError:
    print("ERROR: Reverse fastq '%s' not found or not accessible"%(str(args.fastq_reverse)))
    sys.exit(1)

filtered_seqs=[]
total_count=0

while True:
    seqnamef=fastqf.readline()
    if seqnamef == '':
        break
    if seqnamef[0] != "@":
        print ("Bad Format Error")
        sys.exit()
    seqf=fastqf.readline()
    sepf=fastqf.readline()
    qualf=fastqf.readline()
    seqnamer=fastqr.readline()
    seqr=fastqr.readline()
    sepr=fastqr.readline()
    qualr=fastqr.readline()
    qualf_tr=TranslateQual(qualf.strip("\n"))
    qualr_tr=TranslateQual(qualr.strip("\n"))
    total_count+=1
    if (sum(qualf_tr)/len(qualf_tr)) >= meanscore and (sum(qualf_tr)/len(qualf_tr)) >= meanscore:
        filtered_seqs.append((FastqSeq(seqnamef,seqf,sepf,qualf),FastqSeq(seqnamer,seqr,sepr,qualr)))

fname=str(args.out_prefix)+".forward.fastq"
rname=str(args.out_prefix)+".reverse.fastq"
savefilef=open(fname,'w')
savefiler=open(rname,'w')

filter_count=len(filtered_seqs)

if len(filtered_seqs) <= nbseqs :
    print("WARNING, Not enough sequences remain for random selection")
    print("All sequences will be extracted")
    for i in filtered_seqs:
        i[0].fastq_write(savefilef)
        i[1].fastq_write(savefiler)
    savefilef.close()
    savefiler.close()


if len(filtered_seqs) > nbseqs :
        print("Random Selection in progress...")
        rand_select=random.sample(filtered_seqs,nbseqs)
        filtered_seqs=[]
        for i in rand_select:
            i[0].fastq_write(savefilef)
            i[1].fastq_write(savefiler)
        savefilef.close()
        savefiler.close()

if args.report_output != None:
        reportfile=open(args.report_output,'w')
        reportfile.write("Date: "+str(datetime.date.today())+"\n")
        reportfile.write("Forward Filename: %s\n"%(args.fastq_forward))
        reportfile.write("Reverse Filename: %s\n"%(args.fastq_reverse))
        reportfile.write("Minimal Score Mean: %d\n"%(meanscore))
        reportfile.write("Selection count: %d\n"%(nbseqs))
        reportfile.write("Random State file: %s\n"%(args.random_statefile))
        reportfile.write("Forward Outfile: %s\n"%(fname))
        reportfile.write("Reverse Outfile: %s\n"%(rname))
        reportfile.write("Total sequence count: %d\n"%(total_count))
        reportfile.write("Filtered sequence count: %d\n"%(filter_count))
        if filter_count <= nbseqs :
          reportfile.write("WARNING: Not enough filtered sequences for random selection")

        reportfile.close()

sys.exit(0)

print("Program DONE")    
