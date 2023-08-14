for i in $(seq 11 32)
do
    mogrify -resize 480x320! "AlterEgoFace$i.png"
done
