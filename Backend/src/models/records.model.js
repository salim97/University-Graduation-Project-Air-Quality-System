const mongoose = require("mongoose");

const recordsSchema = new mongoose.Schema(
  {
    uid: {
      type: String,
      required: true,
    },
    GPS: {
      latitude:{
        type:Number,
        required:true
      },
      longitude: {
        type:Number,
        required:true
      },
    },
    Sensors:[{
      name : {
        type:String,
        required:true
      },
      value : {
        type:String,
        required:true
      },
      metric: String,
      isCalibrated:{
        type:Boolean,
        required:true
      },
    }
      ],
      createdAt: String
  },
  {
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

const records = mongoose.model("records", recordsSchema);

module.exports = records;
