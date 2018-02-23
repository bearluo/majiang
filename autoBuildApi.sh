rm -r res_temp
encrypt_res.sh -i res -o res_temp -ek woyaopoker -es poker
rm -r res_temp/icon
cp -r -f res/icon res_temp
compile_scripts.sh -i src -o res_temp/game.zip -e xxtea_zip -ek woyaopoker -es poker
compile_scripts.sh -i src -o res_temp/game64.zip -e xxtea_zip -ek woyaopoker -es poker -b 64
rm -f res_temp/project.manifest
rm -f res_temp/version.manifest
python GenHotUpdate.py
