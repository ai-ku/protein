export PATH := ../hermite:${PATH}

# MATLAB Command
MATLABROOT = /mnt/opt/matlab/linux64/R2011a/bin

NHERMITE = 32
# These two variable can be assigned by MATLAB function result
NSAMPLE = 3000
NDIM = 2184 
# DCD file can be split small parts
SFRAME = 916
EFRAME = 8916

all:

%_f1gen_dR.dat: %.mat %_f1gen_dr.dat
	${MATLABROOT}/matlab -nojvm -nodisplay -r "dr2dR('$*', '$*_f1gen_dr.dat'); exit;"

%_f0gen_dR.dat: %.mat %_f0gen_dr.dat
	${MATLABROOT}/matlab -nojvm -nodisplay -r "dr2dR('$*', '$*_f0gen_dr.dat'); exit;"

# f1 distribution samples
%_f1gen_dr.dat: f1gen.pl
	f1gen.pl -1 $*.one -n${NSAMPLE} > $@

# f0 distribution samples
%_f0gen_dr.dat:
	perl -MMath::Random -e 'for (1..${NSAMPLE}){print join("\t", random_normal(${NDIM}))."\n";}' > $@

# Generates expectations
%.one: %_dr.dat
	one.pl -h ${NHERMITE} $*_dr.dat > $@

# Generates dr coordinates
%_dr.dat: %.mat
	${MATLABROOT}/matlab -nojvm -nodisplay -r "write_coordinates('$*', 'dr'); exit;"

# Generates dR coordinates
%_dR.dat: %.mat
	${MATLABROOT}/matlab -nojvm -nodisplay -r "write_coordinates('$*', 'dR'); exit;"

# Generates MATLAB data files for mode space etc.
%.mat: %.dcd %.pdb
	${MATLABROOT}/matlab -nojvm -nodisplay -r "generate_data('$*'); exit;"
#	${MATLABROOT}/matlab -nojvm -nodisplay -r "generate_data('$*','','${SFRAME}','${EFRAME}'); exit;"


# Removes solvent atoms using Carma package and generate trajectory only CA atoms
# If all atoms excluding solvent is needed use '-atmid ALLID -segid A' instead of '-atomid CA' 
%.dcd:
	@echo $*_wb.dcd and $*_wb.dcd reading...
	./carma64 -v -w -fit -atomid CA $*_wb.dcd $*_wb.psf
	mv carma.fitted.dcd $*.dcd
# Remove unnecessary files
#	rm carma.fit-rms.dat
#	rm carma.selected_atoms.psf

%.pdb:
	@echo Generating CA pdb file...
	./carma64 -v -pdb -atomid CA -first 1 -last 1 $*_wb.dcd $*_wb.psf
	mv $*_wb.dcd.0000001.pdb $*.pdb

#carma: carma.c
#	gcc -O carma.c -lnr -lm
# Need LAPACK package

.PRECIOUS: %.dcd %.psf %.one %.two %.mat %_dR.dat %_dr.dat %_f0gen_dr.dat %_f0gen_dR.dat %_f1gen_dr.dat %_f1gen_dR.dat




