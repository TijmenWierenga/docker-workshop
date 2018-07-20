<?php
require_once 'vendor/autoload.php';

$loop = React\EventLoop\Factory::create();
$counter = 0;

$loop->addPeriodicTimer(1, function () use (&$counter, $loop) {
    $counter++;
    echo $counter . PHP_EOL;

    if ($counter >= 10) {
        $loop->stop();
    }
});

$loop->run();
