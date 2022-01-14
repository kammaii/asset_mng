const functions = require('firebase-functions');
const nodemailer = require("nodemailer");
const admin = require('firebase-admin');
const rp = require('request-promise');
const url = 'https://en.wikipedia.org/wiki/List_of_Presidents_of_the_United_States';
const cheerio = require('cheerio');
const { StringDecoder } = require('string_decoder');
const fs = require('fs');
const readline = require('readline');
const puppeteer = require('puppeteer');

// var serviceAccount = require("G:/keys/asset-manager-271ba-firebase-adminsdk-ggtbe-55a38d9604.json");

// function deploy 전에 실행할 것
// export GOOGLE_APPLICATION_CREDENTIALS="G:/keys/asset-manager-271ba-firebase-adminsdk-ggtbe-55a38d9604.json"
// functions랑 호스팅 에뮬레이터 실행
// firebase emulators:start --only functions,hosting

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  databaseURL: "https://asset-manager-271ba.firebaseio.com"
  // databaseURL: "http://localhost:4000/firestore"
});


// var admin = require("firebase-admin");
//
// // var serviceAccount = require("path/to/serviceAccountKey.json");
//
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });



let stockCodes = [];

async function processLineByLine() {
  stockCodes = require('fs').readFileSync('code.txt', 'utf-8')
      .split('\n')
      .filter(Boolean);
}



function connectStock (successFn, errorFn, index) {
  let stockCode = stockCodes[index].trim();
  let url = 'http://comp.fnguide.com/SVO2/ASP/SVD_Main.asp?pGB=1&gicode=A' + stockCode +'&cID=&MenuYn=Y&ReportGB=&NewMenuID=11&stkGb=701';

  console.log(stockCode);
  rp(url)
  .then(function(html){
    successFn(html);
    // if(index < 10) {
    //   connectStock(successFn, errorFn, index+3);
    // }
  })
  .catch(function(err){
    errorFn(err, url);
  });
}

// 0. 환율 가져오기 안됨
// 1. stock 으로 아이템 만들기
// 2. stockPrice 랑 stockNo 를 regex 하기
// 3. 값들을 숫자로 바꾸기
// 4. description 이 2부분으로 되어있는데 다 가져오기
// 5. 좀 더 빠르게 할 때 2개씩 넣으면 퐁당퐁당으로 가져오는 문제 있음
// 6. 내가 원하는 값들을 DB에 저장하기

function onConnectSuccess(html) {
  let ch = cheerio.load(html);
  let name = ch('#giName').text();
  let equityHoldings;
  let roe;
  let stocksNo;
  let requiredReturnRate = 8.21;
  let stockPrice;
  let description;
  try{
    equityHoldings = ch('#highlight_D_A > table > tbody > tr:nth-child(10) > td:nth-child(4)').text();
    roe = ch('#highlight_D_A > table > tbody > tr:nth-child(18) > td:nth-child(5)').text();
    stocksNo = ch('#svdMainGrid1 > table > tbody > tr:nth-child(7) > td:nth-child(2)').text();
    stockPrice = ch('#svdMainGrid1 > table > tbody > tr:nth-child(1) > td:nth-child(2)').text();
    console.log(name);
    console.log(stocksNo);
    let split = stockPrice.split('/ ');
    console.log('stockPrice' + stockPrice);
    // let stockAmount = parseInt(split[0].replaceAll(',', '')) + parseInt(split[1].replaceAll(',', ''));
    // console.log(stockAmount);
    // description = ch('#bizSummaryContent');
    // //console.log(description);
    // let child = description.children('li');
    // console.log(child.text());

    //var stock = newStock(name, stockPrice);
    let stock = {
        name: name,
        price: stockPrice
      }

    console.log(stock);
    saveDB(stock);

  }catch(e){
    roe = 'N/A';
  }
  //checkSRim();
}

// stocks / stockName
// currency / dollar


function saveDB(stock) {
  console.log('savedb');
  let db = admin.firestore();
  let doc = db.collection('stocks').doc(stock.name);
  let result = doc.set(stock);
  console.log(result);
}

function onConnectError(error, url) {
  console.log(url);
  console.log('error' + error);
}

function checkSRim() {
  let price;
  price = (equityHoldings + equityHoldings * ((roe-requiredReturnRate)/requiredReturnRate) + 100000000)/stocksNo;
  if(price < stockPrice) {
    console.log(name);
  }
}

function newStock(name, price) {
  return {
    name: name,
    price: price
  }
}


function getCurrencyRate() {
  let url = 'https://finance.daum.net/exchanges';

  puppeteer
    .launch()
    .then(function(browser) {
      return browser.newPage();
    })
    .then(function(page) {
      return page.goto(url).then(function() {
        return page.content();
      });
    })
    .then(function(html) {
      let ch = cheerio.load(html);
      let dollarRate;
      dollarRate = ch('#boxContents > div:nth-child(2) > div:nth-child(2) > div > table > tbody > tr:nth-child(1) > td:nth-child(3) > span').text();
      console.log(dollarRate);
    })
    .catch(function(err) {
      console.log('err');
    });
}


function scraping() {
  processLineByLine();
  connectStock(onConnectSuccess, onConnectError, 0);
  connectStock(onConnectSuccess, onConnectError, 1);
  connectStock(onConnectSuccess, onConnectError, 2);
}

exports.scraping = functions.https.onRequest((request, response) => {
  //getCurrencyRate();
  scraping();
  response.send('success');
});

exports.scrapingSchedule = functions.pubsub.schedule('22:35').onRun((context) => {
  scraping();
  return null;
});
