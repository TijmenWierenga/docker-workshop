<?php
require_once 'vendor/autoload.php';

$loop = React\EventLoop\Factory::create();

$redis = new \Predis\Client([
    'scheme' => 'tcp',
    'host'   => 'redis',
    'port'   => 6379,
]);

$total = (int) $redis->get("count");

$counter = 0;

$loop->addPeriodicTimer(1, function () use (&$counter, $loop, $redis, $total) {
    $counter++;
    echo $total + $counter . PHP_EOL;

    $redis->incr("count");

    if ($counter >= 10) {
        $loop->stop();
    }
});

$loop->run();
