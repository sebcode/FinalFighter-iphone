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
echo "b2FixtureDef def;";

foreach ($x->evaluate('//svg:path') as $n) {
	parseData($n->getAttribute('d'));
}

function parseData($d)
{
	$oldx = -1;
	$oldy = -1;
	
	$startx = -1;
	$starty = -1;

	$relative = true;

	$data = explode(' ', $d);

	foreach ($data as $pos) {
		if ($pos == 'M') {
			$relative = false;
			continue;
		}

		if ($pos == 'm') {
			$relative = true;
			continue;
		}

		if (strpos($pos, ',') !== false) {
			list($x, $y) = explode(',', $pos);

			if ($startx == -1 && $starty == -1) {
				//echo '// float startx = ' . $x . ";\n";
				//echo '// float starty = ' . $y . ";\n";
				$startx = $x;
				$starty = $y;
			} else if ($relative) {
				$x = $oldx + $x;
				$y = $oldy + $y;
			}
	
			if ($oldx != -1 && $oldy != -1) {
				gencode($oldx, $oldy, $x, $y);
			}

			$oldx = $x;
			$oldy = $y;
		}
	}

	gencode($oldx, $oldy, $startx, $starty);
}

function gencode($x1, $y1, $x2, $y2)
{
	global $levelH;
	// translate coordinate system
	$y1 = $levelH - $y1;
	$y2 = $levelH - $y2;
	
	echo 'levBox.Set(b2Vec2((float)'.$x1.'/PTM_RATIO, (float)'.$y1.'/PTM_RATIO), b2Vec2((float)'.$x2.'/PTM_RATIO, (float)'.$y2.'/PTM_RATIO));' . "\n";
	echo 'def.shape = &levBox;' . "\n";
	echo 'def.density = 0;' . "\n";
	echo 'def.filter.categoryBits = catWall;' . "\n";
	echo 'def.filter.maskBits = catAll;' . "\n";
	echo 'levBody->CreateFixture(&def);' . "\n";
}

