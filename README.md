# auto-punch-terraform

```
1. terraform init

2. terraform apply

3. go to email to verify to continue applying
```

## Flow

![auto-punch-flow](https://github.com/coffeey0128/auto-punch-terraform/blob/main/auto-punch-terraform.jpg?raw=true)

## 動機

因每次偶爾會忘記在抵達公司及下班後打開手機APP進行打卡，且打卡距離有限制，故打算利用自動化來實施打卡系統。

## 過程

1. 從proxyman攔截手機封包，發現打卡所需的資訊只需要利用自己帳號固定的PID.CID.TOKEN進行login refresh，再帶入Device ID 及座標即可打卡，總共只需戳兩隻API好。
2. 一開始是使用Github Action來進行排程，但實作後發現到規定時間後程式啟動的速度非常久(約10-20分)，擔心會超過打卡時間。
3. 以往的Cron job都是包成image放入ECS執行，後來選擇使用AWS EventBridge來實作排程，再觸發AWS Lambda來進行打卡。
4. 因為會對打卡是否成功導致需要花心思再打開APP確認，所以使用SNS做為Lambda結束的Destination，再subscribe該topic，以EMAIL發送打卡結果。

## 優化

1. (Done)將打卡時間設定為時段內隨機，看起來較不突兀，但要注意工作時間需要滿足上班時數。
    1. 一開始想直接在lambda sleep，但一來花費高，二來lambda會timeout。
    2. 最後使用sqs來實作，多一組lambda來設隨機時間給sqs，SQS會在時間到才開放comsumer使用訊息。
        
        (eventBridge>lambda>sqs>lambda)
        
    3. 需要設定給前後兩個lambda使用該SQS的權限。

2. (Done)將取得200改為call 獲得打卡時間的API，確認有打到卡。

3. 取得休假API，以免請假還會打卡。
    1. (Done)判斷國定例假日。
    2. 自己請假的還無法判斷。
        1. 需要從已簽核的假單api 取得所有請假list。
        2. 需要從list撈summary字串有沒有符合當日日期。
        3. 若請假超過三天,2022/01/01~2022/01/03 -> 照上面邏輯會抓不到2022/01/02。