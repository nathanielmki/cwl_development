class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
baseCommand: [ /opt/software/external/transdecoder/TransDecoder/TransDecoder.Predict ]
inputs:
  - id: geneticCode
    type: TransDecoder-v5-genetic_codes.yaml#genetic_codes?
    inputBinding:
      position: 0
      prefix: '-G'
    label: genetic code
    doc: >-
      genetic code (default: universal; see PerlDoc; options: Euplotes,
      Tetrahymena, Candida, Acetabularia)
  - id: longOpenReadingFrames
    type: Directory
  - id: noRefineStarts
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--no_refine_starts'
    label: No refine starts
    doc: >-
      Start refinement identifies potential start codons for 5' partial ORFs
      using a PWM, process on by default.
  - id: retainBlastpHits
    type: string?
    inputBinding:
      position: 0
      prefix: '--retain_blastp_hits'
    label: Retain Blastp hits
    doc: |
      blastp output in '-outfmt 6' format.
      Any ORF with a blast match will be retained in the final output.
  - id: retainLongOrfsLength
    type: int?
    inputBinding:
      position: 0
      prefix: '--retain_long_orfs_length'
    label: Retain long ORFs length
    doc: >
      Under 'strict' mode, retain all ORFs found that are equal or longer than
      these many nucleotides

      even if no other evidence marks it as coding (default: 1000000) so
      essentially turned off by default.
  - id: retainLongOrfsMode
    type: string?
    inputBinding:
      position: 0
      prefix: '--retain_long_orfs_mode'
    label: Retain long ORFs mode
    doc: >-
      'dynamic' (default) or 'strict'. In dynamic mode, sets range according to
      1%FDR in random sequence of same GC content.
  - id: retainPfamHits
    type: string?
    inputBinding:
      position: 0
      prefix: '--retain_pfam_hits'
    label: Retain Pfam hits
    doc: >
      Domain table output file from running hmmscan to search Pfam (see
      transdecoder.github.io for info).

      Any ORF with a pfam domain hit will be retained in the final output.
  - id: singleBestOnly
    type: boolean?
    inputBinding:
      position: 0
      prefix: '--single_best_only'
    label: Single best only
    doc: >-
      Retain only the single best ORF per transcript (prioritized by homology
      then ORF length)
  - id: train
    type: int?
    inputBinding:
      position: 0
      prefix: '-T'
    label: minimum protein length
    doc: >
      If no --train, top longest ORFs to train Markov Model (hexamer stats)
      (default: 500)

      Note, 10x this value are first selected for removing redundancies,

      and then this -T value of longest ORFs are selected from the non-redundant
      set.
  - format: 'edam:format_1929'
    id: transcriptsFile
    type: File
    inputBinding:
      position: 0
      prefix: '-t'
    label: transcripts.fasta
    doc: FASTA formatted sequence file containing your transcripts.
outputs:
  - id: bed_output
    type: File
    outputBinding:
      glob: $(inputs.transcriptsFile.basename).transdecoder.bed
    format: 'edam:format_3003'
  - id: coding_regions
    type: File
    outputBinding:
      glob: $(inputs.transcriptsFile.basename).transdecoder.cds
    format: 'edam:format_1929'
  - id: gff3_output
    type: File
    outputBinding:
      glob: $(inputs.transcriptsFile.basename).transdecoder.gff3
    format: 'edam:format_1975'
  - id: peptide_sequences
    type: File
    outputBinding:
      glob: $(inputs.transcriptsFile.basename).transdecoder.pep
    format: 'edam:format_1929'
doc: >
  TransDecoder identifies candidate coding regions within transcript sequences,
  such as those generated by de novo RNA-Seq transcript assembly using Trinity,
  or constructed based on RNA-Seq alignments to the genome using Tophat and
  Cufflinks.

  TransDecoder identifies likely coding sequences based on the following
  criteria:
        + a minimum length open reading frame (ORF) is found in a transcript sequence
        + a log-likelihood score similar to what is computed by the GeneID software is > 0.
        + the above coding score is greatest when the ORF is scored in the 1st reading frame
        as compared to scores in the other 2 forward reading frames.
        + if a candidate ORF is found fully encapsulated by the coordinates of another candidate ORF,
        the longer one is reported. However, a single transcript can report multiple ORFs 
        (allowing for operons, chimeras, etc).
        + a PSSM is built/trained/used to refine the start codon prediction.
        + optional the putative peptide has a match to a Pfam domain above the noise cutoff score.
        
  Please visit https://github.com/TransDecoder/TransDecoder/wiki for full
  documentation.

  Releases can be downloaded from
  https://github.com/TransDecoder/TransDecoder/releases
label: 'TransDecoder.Predict: Perl script, which predicts the likely coding regions'
requirements:
  - class: SchemaDefRequirement
    types:
      - $import: TransDecoder-v5-genetic_codes.yaml
  - class: ResourceRequirement
    coresMin: 2
    ramMin: 50
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.transcriptsFile)
      - entryname: $(inputs.transcriptsFile.basename).transdecoder_dir
        entry: $(inputs.longOpenReadingFrames)
        writable: true
  - class: InlineJavascriptRequirement
hints:
  - class: DockerRequirement
    dockerPull: 'biocontainers/transdecoder:v5.0.1-2-deb_cv1'
