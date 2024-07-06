#!/bin/bash 

echo ""
if [ -z $1 ] || [ ! -e $1 ]; then
   #
   echo "which file? usage:";
   echo "Phonopy_qe_craete.sh  <pwscf.in(ibrav=0)> <dim ' 1 1 1'> <output_folder name>"; exit;
   #
fi

echo "  this scripte help you to create phonopy suprcell file frim scf.in \\n"
echo " it's noticeable that 'ibrav' must be '0' and make sure the header.in file exist"
echo "which content the necessary setting information to add to suprcell-xxx.in "


phonopy --qe -d --dim="$2" -c $1


line=$(grep '^!' supercell.in | head -n 1)
nat=$(echo "$line" | awk -F '= ' '{print $3}' | awk '{print $1}')
ntyp=$(echo "$line" | awk -F '= ' '{print $4}'| awk '{print $1}')

n_atoms_line=$(grep 'nat' "$1")
key_nt=${n_atoms_line%%=*}
value_nt=$(echo ${n_atoms_line#*=} | tr -dc '0-9')
pos_index=$(grep -n '^ATOMIC_POSITIONS' "$1" | cut -d ':' -f 1)
cell_index=$(grep -n '^CELL_PARAMETERS' "$1" | cut -d ':' -f 1)
cell_index_ends=$(($cell_index+3))
pos_index_ends=$(($pos_index+$value_nt))

echo " the intail number of atoms = $value_nt, $cell_index , $pos_index"
cp "$1"  header.in

sed -i "${pos_index},${pos_index_ends}d; ${cell_index},${cell_index_ends}d" header.in



echo " nat = $nat  and ntyp=$ntyp "
echo " replace nat and ntyp in header.in file or let as then click to conitnue :     nat =  natoms_ , ntyp = ntypes_,"
wait 

for file in $(find . -name "supercell-*.in"); do 
	base=$(basename "$file")
	i=${base#supercell-}
	i=${i%.in}
        if test -f "header.in"; then 
	   sed -i 's/natoms_/$nat/g' header.in 
	   sed -i "s/ntypes_/$ntyp/g" header.in
        else
                
		echo " the file header.in don't exist"
		exit
	fi
        mkdir "$3_$i"	
	cat header.in "$file" > "$3_$i/$3-$i.in"
	rm supercell-$i.in
done
