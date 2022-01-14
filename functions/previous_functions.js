const functions = require('firebase-functions');
const nodemailer = require("nodemailer");
const admin = require('firebase-admin');
// var serviceAccount = require("C://akoreanKeyStore_podo/podo-705c6-firebase-adminsdk-6ks88-c8eaabba97.json");

// function deploy 전에 실행할 것
// export GOOGLE_APPLICATION_CREDENTIALS="C://akoreanKeyStore_podo/podo-705c6-firebase-adminsdk-6ks88-c8eaabba97.json"
// functions랑 호스팅 에뮬레이터 실행
// firebase emulators:start --only functions,hosting

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  //databaseURL: "https://podo-705c6.firebaseio.com"
  databaseURL: "http://localhost:4000/firestore"
});

let messaging = admin.messaging();
let lastCheckedEmail = Date.now()/1000;

function findInactiveUsers() {
  console.log('starting findInactiveUsers');
  let yearMs = 1000 * 60 * 60 * 24 * 365;
  let now = Date.now();
  let oneWeek = (now + 1000 * 60 * 60 * 24 * 7) / 1000;
  let db = admin.firestore();
  console.log(now - yearMs);
  let users = db.collection('android').doc('podo').collection('users');
  //let inactiveUsers = users.where("lastVisit", "<", Date.parse('25 Feb 2020 00:00:00 GMT'))
  let inactiveUsers = users.where("lastVisit", "<", (now - yearMs)/1000).get();
  inactiveUsers.then((querySnapshot) => {
          querySnapshot.forEach((doc) => {
              // doc.data() is never undefined for query doc snapshots
              const userRef = db.collection('android/podo/users').doc(doc.id);

              if(doc.lastCheckedEmail && doc.lastCheckedEmail > lastVisit) {
                console.log('They didn\'t visit again');
                // todo: remove user
              } else {
                userRef.update ({
                  lastCheckedEmail: lastCheckedEmail,
                });
                sendEmailForInActiveUser();
              }
              console.log(doc.id, " => ", doc.data());
              console.log(inactiveUsers);
          });
      })
      .catch((error) => {
          console.log("Error getting documents: ", error);
      });
      return inactiveUsers;
}


function createWritingDB() {
  console.log("DB 시작!");
  let db = admin.firestore();

  let podoDoc = db.collection('android').doc('podo');
  podoDoc.set({id: 'podo'});
  let writingDoc = podoDoc.collection('writings').doc('0000-0000-0000');
  writingDoc.set({
    contents: '안녕하세요',
    correction: '교정',
    dateAnswer: '',
    dateRequest: '',
    guid: 'c8a9acb5-bfb1-4536-a31e-a30392c8dfcb',
    letters: '',
    status: 1,
    studentFeedback: '',
    teacherFeedback: '잘했어요',
    teacherId: 'danny',
    teacherName: 'Danny Park',
    userEmail: 'gabmanpark@gmail.com',
    userName: 'danny',
    userToken: 'eYLTFADIJSs:APA91bE2EqO4fdVUQGoz8ysTq9epL8SSMeKPmIiyjMRRrKGYVRg4AXInIx1wA_6sSIT33xst7gM7tvL4k_XS968WBjfeKLlIXZKZQxH3BpNNuC0TsmmMlG5lAAPzkX2UetxwKvneJnxQ',
    writingDate: '1592262099'
  });

  return 'success'
}


function createInactiveUserDB() {
  console.log("DB 시작!");
  let virtualUsersEmail = ["first@gmail.com", "second@gmail.com", "third@gmail.com", "fourth@gmail.com", "fifth@gmail.com"];
  let virtualUsersLastVisit = [1580000000, 1580000000, 1580000000, 1600000000, 1600000000]; // 1~3: 2020년 1월, 4~5: 2020년 9월
  let db = admin.firestore();

  let podoDoc = db.collection('android').doc('podo');
  podoDoc.set({id: 'podo'});

  for(i=0; i<virtualUsersEmail.length; i++) {
    let usersDoc = podoDoc.collection('users').doc(virtualUsersEmail[i]);
      usersDoc.set({
        lastVisit: virtualUsersLastVisit[i],
      });
  }

  return 'success'
}


function createReportDB() {
  console.log("DB 시작!");
  let db = admin.firestore();

  let podoDoc = db.collection('android').doc('podo');
  podoDoc.set({id: 'podo'});
  let reportDoc = podoDoc.collection('reports').doc('0000-0000-0000');
  reportDoc.set({
    comments: 'I suggest ...',
    answer: 'podo answers ...blabla',
    date: 1596685122,
    status: 0,
    userEmail: 'kammaii@naver.com',
    userName: 'Danny Park',
    userToken: 'eYLTFADIJSs:APA91bE2EqO4fdVUQGoz8ysTq9epL8SSMeKPmIiyjMRRrKGYVRg4AXInIx1wA_6sSIT33xst7gM7tvL4k_XS968WBjfeKLlIXZKZQxH3BpNNuC0TsmmMlG5lAAPzkX2UetxwKvneJnxQ'
  });

  return 'success'
}



function sendMessage(token, payload) {
  return messaging.sendToDevice(token, payload)
    .then(function(response){
      console.log('Notification sent successfully:',response);
      return response;
    })
    .catch(function(error){
      console.log('Notification sent failed:',error);
    });
}


function onQnAReply(change, context) {
  let status = change.after.data().status;
  let studentEmail = change.after.data().userEmail;
  let question = change.after.data().question;
  let answer = change.after.data().answer;
  if(status === 2) {
    const payload = {
      data: {
      },
      notification: {
        title: 'Your question has been answered.',
        body: 'Please check Q&A menu.'
    }};
    sendMessage(change.after.data().userToken, payload);
  }

  return true;
}



function onCommentReply(change, context) {
  let status = change.after.data().status;
  let studentEmail = change.after.data().userEmail;
  let comments = change.after.data().comments;
  let answer = change.after.data().answer;
  if(status === 2) {
    const payload = {
      data: {
      },
      notification: {
        title: 'Find our response to your comment',
        body: 'Please check your email !'
    }};
    sendMessage(change.after.data().userToken, payload);
    sendEmailForComment(studentEmail, comments, answer);
  }

  return true;
}


function onWritingChange(change, context) {
  //let data = change.after.data();
  //let status = data.status;
  console.log('!!!!! A Writing has Changed !!!!!');
  console.log(context.params.writingId);
  console.log(context.eventType);
  console.log('BEFORE:');
  console.log(change.before.data());
  console.log('AFTER:');
  console.log(change.after.data());
  let studentEmail = change.after.data().userEmail;
  let status = change.after.data().status;
  let contents = change.after.data().contents;
  let correction = change.after.data().correction;
  let guid = change.after.data().guid;
  let teacherFeedback = change.after.data().teacherFeedback;
  let studentFeedback = change.after.data().studentFeedback;

  // 교정 완료하거나 재요청 하면 클라우드 메시지 보냄
  if(status === 2 || status === 99) {
    let title;
    let body;
    let statusString;

    if(status === 2) {
      title = "Your writing has been corrected";
      body = "check your writing";
      statusString = "2";
    } else {
      title = "Your writing has been returned";
      body = "Please write more clearly and send it again.\n* Your point has been returned to you.";
      statusString = "99";
    }

    const payload = {
      data: {
        status: statusString,
        guid: guid,
        contents: contents,
        correction: correction,
        teacherFeedback: teacherFeedback
      },
      notification: {
        tag: "writing",
        title: title,
        body: body
      }
    };
    sendMessage(change.after.data().userToken, payload);

  // 학생이 피드백 보내면 나한테 메일 보냄
  } else if(status === 3) {
    sendEmailForWritingFeedback(studentEmail, contents, correction, teacherFeedback, studentFeedback);
  }

  return true;
}


function sendAlarm() {
  // step0 :
  // step1 : get time from the database

  console.log("알람!");
}


let sendEmailToInactiveUsers = function(studentEmail) {
  console.log("학생이메일" + studentEmail);

  let transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "akorean.app@gmail.com", // generated ethereal user
      pass: "gabman84" // generated ethereal password
    }
  });

  // send mail with defined transport object
  let mailSubject = "[podo] Responses to your comment";
  let mailContents =
  "<b>'podo' hears from you!</b><br><br>"
  + "Thank you for your valuable opinion.<br><br>"
  + answer + "<br><br>"
  + "Sincerely<br><br>"
  + "<img src='https://firebasestorage.googleapis.com/v0/b/podo-705c6.appspot.com/o/logo.png?alt=media&token=9665bfa8-7c96-4a93-897d-848e11fe48d5' alt='podo' width='190' height='90'>";

  transporter.sendMail({
    from: "akorean.app@gmail.com", // sender address
    to: studentEmail, // list of receivers
    subject: mailSubject, // Subject line
    //text: "Hello world?", // plain text body
    html: mailContents // html body
  });
}


exports.findInactiveUsersHttp = functions.https.onRequest((request, response) => {

  findInactiveUsers().then(function(result) {
    console.log('result :' + result);
    let db = admin.firestore();
    // const batch = db.batch();
    let count = 0;
    // result.forEach((doc) => {
        // count++;
        // doc.data() is never undefined for query doc snapshots
        // console.log(doc.id, " => ", doc.data());
        // const userRef = db.collection('android/podo/users').doc(doc.id);
        // batch.update(userRef, {
        //   lastCheckedEmail: lastCheckedEmail,
        //   testUser: true
        // });
    // });
    // console.log('count :' + count);
    // batch.commit();
    response.send(new Date());
  })
  .catch((error) => {
      console.log("Error getting documents: ", error);
      response.send(error);
  });
});

exports.findInactiveUsers = functions.pubsub.schedule('every 1 minutes').onRun((context) => {
  findInactiveUsers();
  return null;
});


exports.scheduledFunction = functions.pubsub.schedule('every 5 minutes').onRun((context) => {
  sendAlarm();
  return null;
});


exports.createWritingDB = functions.https.onRequest((request, response) => {
  let result = createWritingDB();
  response.send(result);
});

exports.createInactiveUserDB = functions.https.onRequest((request, response) => {
  let result = createInactiveUserDB();
  response.send(result);
});


exports.createReportDB = functions.https.onRequest((request, response) => {
  let result = createReportDB();
  response.send(result);
});


exports.onCommentReply = functions
  .firestore.document('android/podo/reports/{reportsId}')
  .onWrite(onCommentReply);


exports.onWritingChange = functions
  .firestore.document('android/podo/writings/{writingId}')
  .onWrite(onWritingChange);


exports.onQnAReply = functions
  .firestore.document('android/podo/qna/{qnaId}')
  .onWrite(onQnAReply);


let sendEmailForInActiveUser = function(email) {
  console.log('Email sent : ' + email);
}

let sendEmailForWritingFeedback = function(studentEmail, contents, correction, teacherFeedback, studentFeedback) {
  console.log("커렉션" + correction);
  console.log("학생피드백" + studentFeedback);
  // create reusable transporter object using the default SMTP transport
  let transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "akorean.app@gmail.com", // generated ethereal user
      pass: "gabman84" // generated ethereal password
    }
  });

  // send mail with defined transport object
  let mailSubject = "학생이 피드백을 보냈습니다.";
  let mailContents =
  "<p><b>학생이메일</b><br>"
  + studentEmail + "</p>"
  + "<p><b>내용</b><br>"
  + contents + "</p>"
  + "<p><b>교정</b><br>"
  + correction + "</p>"
  + "<p><b>선생님 피드백</b><br>"
  + teacherFeedback + "</p>"
  + "<p><b>학생 피드백</b><br>"
  + studentFeedback + "</p>";

  transporter.sendMail({
    from: "akorean.app@gmail.com", // sender address
    to: "akorean.app@gmail.com", // list of receivers
    subject: mailSubject, // Subject line
    //text: "Hello world?", // plain text body
    html: mailContents // html body
  });
}


let sendEmailForComment = function(studentEmail, comments, answer) {
  console.log("학생이메일" + studentEmail);
  console.log("코멘트" + comments);
  console.log("답변" + answer);
  // create reusable transporter object using the default SMTP transport
  let transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "akorean.app@gmail.com", // generated ethereal user
      pass: "gabman84" // generated ethereal password
    }
  });

  // send mail with defined transport object
  let mailSubject = "[podo] Responses to your comment";
  let mailContents =
  "<b>'podo' hears from you!</b><br><br>"
  + "Thank you for your valuable opinion.<br><br>"
  + answer + "<br><br>"
  + "Sincerely<br><br>"
  + "<img src='https://firebasestorage.googleapis.com/v0/b/podo-705c6.appspot.com/o/logo.png?alt=media&token=9665bfa8-7c96-4a93-897d-848e11fe48d5' alt='podo' width='190' height='90'>";

  transporter.sendMail({
    from: "akorean.app@gmail.com", // sender address
    to: studentEmail, // list of receivers
    subject: mailSubject, // Subject line
    //text: "Hello world?", // plain text body
    html: mailContents // html body
  });
}
