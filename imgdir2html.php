<?php

if(!empty($argv[1])){
    $startIdx = $argv[1];
} else {
    $startIdx = "";
}
if(!empty($argv[2])){
    $endIdx = $argv[2];
} else {
    $endIdx = "";
}
$arr = glob('*');
natsort($arr);
$varr = array();
foreach($arr as $f){
    if(!is_dir($f)){
        //not gonna add to varr
    } else {
        //should be added to varr
        if(!preg_match("/$startIdx/", $f) && empty($started)) continue;
        $started = true;
        array_push($varr, $f);
        if(!empty($endIdx) && preg_match("/$endIdx/", $f)) break;
    }
}
$arr = $varr;
//~ var_dump($arr);
?>
<html>
<head>

<style>
div#toc{
    position: fixed;
    left: 0;
    margin: 0 0 0 0;
    padding: 0 0 0 5px;
    overflow: scroll;
    width: 10%;
    height: 100vh;
}
div#toc li{
    text-decoration: none;
    line-height: 25px;
    list-style-type: none;
    margin-left: -35px
       
}
div#imgcont{
    width:90%;
    left:auto;
    right:auto;
    text-align:center;
    padding-left: 5px;
    margin-left: 10%
}

img{
    max-width: 100%;
    min-width: 80%;
    height: auto;
    background-size: contain;
}

</style>
</head>

<body>
<div id="toc">
    <ol>
    <?php 
    foreach($arr as $d){
        $dn = preg_replace('/_/', ' ', $d);
        echo "<li><a href='#$d'>$dn</a></li>";
    }
    ?>
    </ol>
</div>
<div id="imgcont">
<?php
foreach($arr as $f){
    echo "<br><h1 id='$f'>$f</h1><br>";
    $imgarr = glob("$f/*");
    $imgarr = preg_grep("/\.html$/i", $imgarr, PREG_GREP_INVERT);
    natsort($imgarr);
    foreach($imgarr as $img){
        echo "<img src='$img'><br>";
    }
}
?>
</div>
</body>
</html>
