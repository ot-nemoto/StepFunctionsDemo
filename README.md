# StepFunctionsDemo

## 概要

- StepFunctionを AWS SAM を使って構築するデモ
- デモのStepFunctionsでは起動の入力値(value)に対して `((((value / 3) - 3) * 3) + 3)` の結果を返す
- StepFunctionsでは以下のLambdaFunctionをそれぞれタスクとして連携している
  - Divided3Function : 引数の値を 3 で割った結果を返す
  - Minus3Function : 引数の値から 3 を引いた結果を返す
  - Multipled3Function : 引数の値に 3 をかけた結果を返す
  - Plus3Function : 引数の値に 3 を加えた結果を返す
- Step Functions の入力値

```
{ "value" : <数値> }
```

- Step Functions の出力結果

```
{ "value" : <数値> }
```

## デプロイ

```sh
make deploy
```

## Step Functions ステートマシンを直接実行

```sh
STATE_MACHINE_ARN=$(aws cloudformation describe-stacks \
  --stack-name step-functions-demo-stack \
  --query 'Stacks[].Outputs[?OutputKey==`StateMachineArn`].OutputValue' \
  --output text)
echo ${STATE_MACHINE_ARN}

# ((((0.5 / 3) - 3) * 3) + 3)
aws stepfunctions start-execution --state-machine-arn ${STATE_MACHINE_ARN} --input "{\"value\" : \"0.5\"}"
```

## APIからStep Functions ステートマシンを実行

```sh
STEP_FUNCTIONS_API=$(aws cloudformation describe-stacks \
  --stack-name step-functions-demo-stack \
  --query 'Stacks[].Outputs[?OutputKey==`StepFunctionsAPI`].OutputValue' \
  --output text)
echo ${STEP_FUNCTIONS_API}

# ((((0.5 / 3) - 3) * 3) + 3)
value=0.5
curl $(echo ${STEP_FUNCTIONS_API} | sed "s/{value}/${value}/g")
```

## アンデプロイ

```sh
make undeploy
```
