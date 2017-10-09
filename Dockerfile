FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y bowtie software-properties-common cpanminus
RUN apt-add-repository ppa:j-4/vienna-rna
RUN apt-get update
RUN apt-get install -y bedtools vienna-rna
RUN apt-get install -y wget bzip2
RUN apt-get install -y build-essential
RUN apt-get install -y libncurses5-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libbz2-dev
RUN apt-get install -y liblzma-dev

RUN wget https://github.com/samtools/samtools/releases/download/1.5/samtools-1.5.tar.bz2 && tar xf samtools-1.5.tar.bz2 \
    && cd samtools-1.5 && ./configure && make && make install
RUN wget https://github.com/samtools/htslib/releases/download/1.5/htslib-1.5.tar.bz2 && tar xf htslib-1.5.tar.bz2 \
    && cd htslib-1.5 && ./configure && make && make install
RUN wget https://github.com/samtools/bcftools/releases/download/1.5/bcftools-1.5.tar.bz2 && tar xf bcftools-1.5.tar.bz2 \
    && cd bcftools-1.5 && ./configure && make && make install

RUN curl https://raw.githubusercontent.com/MikeAxtell/ShortStack/v3.8.3/ShortStack >ShortStack
RUN chmod a+x ShortStack
ENV PATH /:$PATH

# splitfasta
RUN wget http://augustus.gobics.de/binaries/scripts/splitMfasta.pl
RUN chmod a+x splitMfasta.pl

# infernal
RUN apt-get install -y hmmer infernal

# hmmer2 for rnammer
RUN wget http://eddylab.org/software/hmmer/2.3.2/hmmer-2.3.2.bin.intel-linux.tar.gz && tar xf hmmer-2.3.2.bin.intel-linux.tar.gz \
    && mv hmmer-2.3.2.bin.intel-linux/binaries/hmmsearch hmmer-2.3.2.bin.intel-linux/binaries/hmmsearch2
ENV PATH /hmmer-2.3.2.bin.intel-linux/binaries/:$PATH

# rnammer
RUN  mkdir rnammer-1.2
COPY rnammer-1.2.src.tar.Z /rnammer-1.2/rnammer-1.2.src.tar.Z
RUN  tar -C /rnammer-1.2 -xf /rnammer-1.2/rnammer-1.2.src.tar.Z
RUN  perl -i -plne 's|/usr/cbs/bio/bin/linux64/hmmsearch|/hmmer-2.3.2.bin.intel-linux/binaries/hmmsearch2|' /rnammer-1.2/rnammer
RUN  perl -i -plne 's|/usr/cbs/bio/src/rnammer-1.2|/rnammer-1.2|' /rnammer-1.2/rnammer
ENV  PATH /rnammer-1.2:$PATH
RUN  apt-get install -y libxml-parser-perl
RUN  cpanm XML::Simple
RUN  perl /rnammer-1.2/rnammer -S bac -m lsu,ssu,tsu -gff - < /rnammer-1.2/example/ecoli.fsa

# blast
RUN apt-get install -y ncbi-blast+

# MapMi
RUN cpanm Config::General Bio::Perl
RUN wget http://www.ebi.ac.uk/enright-srv/MapMi/SiteData/MapMi-SourceRelease-1.5.0-b01.zip \
         http://www.ebi.ac.uk/enright-srv/MapMi/SiteData/MapMi-SourceRelease-1.5.9-b32.zip
RUN apt-get install -y unzip nano
RUN unzip MapMi-SourceRelease-1.5.0-b01.zip
RUN perl -i -plne 's|PipelineConfig.conf|/SourceRelease/PipelineConfig.conf|' /SourceRelease/MapMi-MainPipeline-v150b01.pl
RUN cd SourceRelease && tar xf HelperPrograms-Linux.tar.bz2 && unzip ../MapMi-SourceRelease-1.5.9-b32.zip && cd ..
RUN chmod a+x /SourceRelease/*.pl
RUN apt-get install -y lib32stdc++6
ENV PATH /SourceRelease:/SourceRelease/HelperPrograms:$PATH

# miRDeep2
RUN apt-get install -y less nano
RUN cpanm PDF::API2 Font::TTF Compress::Zlib
RUN wget https://www.mdc-berlin.de/45995549/en/research/research_teams/systems_biology_of_gene_regulatory_elements/projects/miRDeep/mirdeep2_0_0_8.zip \
    && unzip mirdeep2_0_0_8.zip \
    && cd mirdeep2_0_0_8 \
    && perl -i -plne 's/checkBIN\("RNAfold.*/system\("RNAfold -h 2"\);/' install.pl \
    && perl install.pl \
    && perl install.pl \
    && touch install_successful

ENV PATH /mirdeep2_0_0_8/bin:$PATH
