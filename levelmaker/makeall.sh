#!/bin/bash

set -e

./makeCollision.php Fragtemple.svg > ../FinalFighter-mac/Fragtemple.inc
./makeCollision.php YerLethalMetal.svg > ../FinalFighter-mac/YerLethalMetal.inc
./makeCollision.php Overkillz.svg > ../FinalFighter-mac/Overkillz.inc
./makeCollision.php HauntedHalls.svg > ../FinalFighter-mac/HauntedHalls.inc

./makeItems.php Fragtemple_Items.svg > ../FinalFighter-mac/Fragtemple_Items.inc
./makeItems.php YerLethalMetal_Items.svg > ../FinalFighter-mac/YerLethalMetal_Items.inc
./makeItems.php Overkillz_Items.svg > ../FinalFighter-mac/Overkillz_Items.inc
./makeItems.php HauntedHalls_Items.svg > ../FinalFighter-mac/HauntedHalls_Items.inc

./makeItems.php Fragtemple_Tutorial_Items.svg > ../FinalFighter-mac/Fragtemple_Tutorial_Items.inc

echo 'Done.'

