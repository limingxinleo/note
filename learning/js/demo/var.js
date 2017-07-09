var x = 1;
var y = 2;
console.log("x+y=" + (x + y));

var arr = [1, 2, 3, 4, 5, 6];
for (var i in arr) {
    console.log('arr[' + i + ']=' + arr[i]);
}

var obj = {
    id:1,
    name:'limx',
    sex:'男',
    sign:'WE CAN DO IT JUST THINK IT!'
};
for (var i in obj) {
    console.log('obj["' + i + '"]=' + obj[i]);
}