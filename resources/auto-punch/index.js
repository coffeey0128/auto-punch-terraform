const axios = require('axios');
const {
    CID, PID, REFRESH_TOKEN, DEVICE_ID, LAT, LNG
} = process.env;

let refreshConfig = {
    method: 'post',
    url: 'https://pro.104.com.tw/prohrm/api/login/refresh',
    headers: {
        'Content-Type': 'application/json',
    },
    data: JSON.stringify({
        "cid": CID,
        "pid": PID,
        "refreshToken": REFRESH_TOKEN
    }),
}

let gpsConfig = {
    method: 'post',
    url: 'https://pro.104.com.tw/prohrm/api/app/card/gps',
    headers: {
        'Authorization': '',
        'Content-Type': 'application/json',
    },
    data: JSON.stringify({
        "deviceId": DEVICE_ID,
        "latitude": LAT,
        "longitude": LNG,
    }),
}
var nowDate = new Date()
let getCardInfo = {
    method: 'post',
    url: 'https://pro.104.com.tw/hrm/psc/apis/public/getDayCardDetail.action',
    headers: {
        'Content-Type': 'application/json',
        'Cookie':'JSESSIONID=B0B5ABE29558D04E5DD329F397EE57CE; AWSALB=PsWijzYfaXBepq6BE%2Fe5NPwTCxp83vvwj1TfcYk7Tr8p94f5aXWMv%2BhXT%2BDN3TQ3pgcO0052ypeLmH82rotWDCICtoLSzk%2Bw2b%2FgsjUKTlNWoYE5fuia4EIYg6NP; AWSALBCORS=PsWijzYfaXBepq6BE%2Fe5NPwTCxp83vvwj1TfcYk7Tr8p94f5aXWMv%2BhXT%2BDN3TQ3pgcO0052ypeLmH82rotWDCICtoLSzk%2Bw2b%2FgsjUKTlNWoYE5fuia4EIYg6NP; CID=4c0cdc47b28d4672ff228e2c54f63fcb; MDMKEY=6cdc2abed90ea7c3f26a7bd760e94496; PID=73253830184d485bb5a79c66652df3fd; proapp=1'
    },
    data: JSON.stringify({
        "cid": CID,
        "pid": PID,
        "date": nowDate.getFullYear()+"/"+(nowDate.getMonth()+1)+"/"+nowDate.getDate(),
    }),
}

let getDayDetail = {
    method: 'post',
    url: 'https://pro.104.com.tw/hrm/psc/apis/public/getDayCardAndCompareDetail.action',
    headers: {
        'Content-Type': 'application/json',
        'Cookie':'JSESSIONID=B0B5ABE29558D04E5DD329F397EE57CE; AWSALB=PsWijzYfaXBepq6BE%2Fe5NPwTCxp83vvwj1TfcYk7Tr8p94f5aXWMv%2BhXT%2BDN3TQ3pgcO0052ypeLmH82rotWDCICtoLSzk%2Bw2b%2FgsjUKTlNWoYE5fuia4EIYg6NP; AWSALBCORS=PsWijzYfaXBepq6BE%2Fe5NPwTCxp83vvwj1TfcYk7Tr8p94f5aXWMv%2BhXT%2BDN3TQ3pgcO0052ypeLmH82rotWDCICtoLSzk%2Bw2b%2FgsjUKTlNWoYE5fuia4EIYg6NP; CID=4c0cdc47b28d4672ff228e2c54f63fcb; MDMKEY=6cdc2abed90ea7c3f26a7bd760e94496; PID=73253830184d485bb5a79c66652df3fd; proapp=1'
    },
    data: JSON.stringify({
        "cid": CID,
        "pid": PID,
        "date":  nowDate.getFullYear()+"/"+(nowDate.getMonth()+1)+"/"+nowDate.getDate(),
    }),
}


async function main(){
    try {
        // 刷新Bearer token
        let res = await axios(refreshConfig)
        console.log("------refresh------")
        console.log(res.data)
        if (res.data.code == 200) {
            gpsConfig.headers.Authorization = `Bearer ${res.data.data}`
        } else {
            throw 'refresh error'
        }
        
        // 取得當日假期狀況來決定是否打卡
        res = await axios(getDayDetail)
        console.log("------Day Detail------")
        console.log(res.data)
        if (res.data.success == true) {
            if(res.data.data[0].isWorkDay==false)
            {
                throw 'no need to punch!'
            }
        } else {
            throw 'getDayCardDetail error'
        }
       
        打卡
        res = await axios(gpsConfig)
        console.log("------gps------")
        console.log(res.data)
        if (res.data.code == 200) {
            gpsConfig.headers.Authorization = `Bearer ${res.data.data}`
        } else {
            throw 'gps error'
        }
        
        
    } catch (e) {
        console.log("------error------")
        console.log(e)
    }
}

var AWS = require("aws-sdk");
exports.handler = async (event) => {
    console.log("------------------Punch Start!!------------------")

    await main()
   
    var message =""
    let nowTime = new Date();
    if (nowTime.getHours()+8<18){
        message+="上班"
    }else{
        message+="下班"
    }
    //  取得當日打卡資訊，寄信告知打卡狀況
    let res = await axios(getCardInfo)
    console.log("------Card Info------")
    console.log(res.data)
    var punchStatus = false
    if (res.data.success == true) {
        if(nowTime.getHours()+8<18){
            if(res.data.data[0].timeStart!=null)
            {
                punchStatus = true
            }
        }else{
            if(res.data.data[0].timeEnd!=null)
            {
                punchStatus = true
            }
        }
    } 
    if (punchStatus){
        message += "打卡成功！\n"
    }else {
        message += "打卡失敗！\n"
    }
    
    message+= (nowTime.getHours()+8)+":" + nowTime.getMinutes() + ":"+nowTime.getSeconds();
    var sns = new AWS.SNS();
        var params = {
            Message: message, 
            Subject: "Punch Status",
            TopicArn: process.env.SNS_PATH
        };
    await sns.publish(params).promise()
 
    
    console.log(message)
    console.log("------------------Punch End!!------------------")
};