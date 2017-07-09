// 整形
var x = 1;
var y = 2;
console.log("x+y=" + (x + y));

// 数组
var arr = [1, 2, 3, 4, 5, 6];
for (var i in arr) {
    console.log('arr[' + i + ']=' + arr[i]);
}

for (var i = 0; i < arr.length; i++) {
    console.log('arr[' + i + ']=' + arr[i]);
}

// 结构体
var obj = {
    id: 1,
    name: 'limx',
    sex: '男',
    sign: 'WE CAN DO IT JUST THINK IT!'
};

for (var i in obj) {
    console.log('obj.' + i + '=' + obj[i]);
}

if (obj.id == 1) {
    console.log('obj.id == 1 is true');
} else {
    console.log('obj.id == 1 is false');
}