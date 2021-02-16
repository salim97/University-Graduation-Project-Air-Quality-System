const thisModel = require('../models/records.model');
const factory = require('../controllers/handlerFactory');
const catchAsync = require('../utils/catchAsync');
const AppError = require('../utils/appError');


getAll = factory.getAll(thisModel);
getOne = factory.getOne(thisModel);
createOne = factory.createOne(thisModel);
// deleteOne = factory.deleteOne(thisModel);
updateOne = factory.updateOne(thisModel);

getLast10minRecords =  catchAsync(async (req, res, next) => {
  const date = new Date();
  const currentDateTime = date.getTime();
  const sample = (10 * 60) * 1000;
  const docs = await thisModel.find({ createdAt: { 
    
  
      $gte: currentDateTime-sample,
  

   } });

  docs.map((doc) => doc.Timestamp).sort();

  // SEND RESPONSE
  res.status(200).json({
    status: "success",
    results: docs.length,
    data: {
      data: docs,
    },
  });
});


//  req.body.Timestamp = new Date().toISOString();

//-----------------------------------------------------------------------------
//      CURD(create, update, read, delete)
//-----------------------------------------------------------------------------
const express = require('express');

const authController = require('../controllers/auth.controller');

const router = express.Router({ mergeParams: true });

router.get('/get_last_10min_records',getLast10minRecords);

//router.use(authController.protect);

router
  .route('/')
  .get(/* authController.restrictTo('admin'), */ getAll)
  .post(/*authController.restrictTo('admin'),*/ createOne);

router
  .route('/:id')
  .get(authController.restrictTo('admin'), getOne)
  .patch(authController.restrictTo('admin'), updateOne)
  .delete(/* authController.restrictTo('admin'), */ deleteOne);

module.exports = router;