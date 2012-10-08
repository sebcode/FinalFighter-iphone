#!/usr/bin/env php
<?php

$d = new DOMDocument;
$d->load($argv[1]);

$x = new DOMXPath($d);
$x->registerNamespace('svg', 'http://www.w3.org/2000/svg');
$x->registerNamespace('xlink', 'http://www.w3.org/1999/xlink');

$levelW = $x->evaluate('number(//svg:image[@id = "map"]/@width)');
$levelH = $x->evaluate('number(//svg:image[@id = "map"]/@height)');

if (!$levelW || !$levelH || is_nan($levelW) || is_nan($levelH)) {
	throw new Exception('could not find map dimensions');
}

echo "// Level size: $levelW x $levelH\n";

foreach ($x->evaluate('//svg:image[not(@id = "map")]') as $n) {
	$w = $n->getAttribute('width');
	$h = $n->getAttribute('height');
	$x = $n->getAttribute('x') + ($w / 2);
	$y = $n->getAttribute('y') + ($h / 2);
	$name = basename($n->getAttribute('xlink:href'), '.png');

	if ($name == 'repair') {
		$type = 'kItem' . ucfirst($name);
	} else if (strpos($name, 'palm') === 0) {
		$type = 'kDecoration' . ucfirst($name);
	} else {
		$type = 'kItemWeapon' . ucfirst($name);
	}

	// translate coordinate system
	$y = $levelH - $y;

	if (strpos($name, 'tank') === 0) {
		switch ($name) {
			case 'tank_right': $rotate = 0; break;
			case 'tank_topright': $rotate = 45; break;
			case 'tank_up': $rotate = 90; break;
			case 'tank_topleft': $rotate = 135; break;
			case 'tank_left': $rotate = 180; break;
			case 'tank_bottomleft': $rotate = 225; break;
			case 'tank_down': $rotate = 270; break;
			case 'tank_bottomright': $rotate = 315; break;
			default: throw new Exception("Unknown tank: " . $tank);
		}

		echo "[self registerPlayerStartCoords:ccp($x, $y) rotate:$rotate]; // $name\n";
		continue;
	}
	
	if (strpos($name, 'palm') === 0) {
		echo "[self registerDecorationWithCoords:ccp($x, $y) type:$type];\n";
		continue;
	}
	
	echo "[self registerItemWithCoords:ccp($x, $y) type:$type];\n";
}

echo "// done\n";

