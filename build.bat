@echo off

echo -Building QuickScoop ......

set compiler=msvc
set name=qs

v -cc %compiler% -prod -skip-unused -o %name% . 
del %name%.exp %name%.lib %name%.pdb 

echo -Finished Buiulding QuickScoop
echo -Try Running "%name% gimp"