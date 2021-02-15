const path = require('path');
const express = require('express');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const hpp = require('hpp');
const cookieParser = require('cookie-parser');
const cors = require('cors')
const AppError = require('./utils/appError');
const globalErrorHandler = require('./controllers/error.controller');


const authService = require('./services/users/auth.services');
const records_service = require('./services/records/records.service');


const app = express();

// Implement CORS
app.use(cors());

// Set security HTTP headers
app.use(helmet());

// Development logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Limit requests from same API
const limiter = rateLimit({
  max: 100,
  windowMs: 60 * 60 * 1000,
  message: 'Too many requests from this IP, please try again in an hour!'
});
// app.use('/api', limiter); // TODO: uncomment this on production 

// Body parser, reading data from body into req.body
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: true, limit: '10kb' }));
app.use(cookieParser());

// Data sanitization against NoSQL query injection
app.use(mongoSanitize());

// Data sanitization against XSS
app.use(xss());

// Prevent parameter pollution
app.use(
  hpp(
  //   {
  //   whitelist: [
  //     'duration',
  //     'ratingsQuantity',
  //     'ratingsAverage',
  //     'maxGroupSize',
  //     'difficulty',
  //     'price'
  //   ]
  // }
  )
);

// Test middleware
app.use((req, res, next) => {
  req.requestTime = new Date().toISOString();
  // console.log(req.cookies);
  next();
});

// 3) ROUTES
app.use('/api/v1/auth', authService);
app.use('/api/v1/records/records_service', records_service);


// Serving static files
app.use(express.static(path.join(__dirname, '../public')));
app.get('/', function(req, res) {
  res.sendFile(path.join(__dirname, '../public', 'index.html'));
});

app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server!`, 404));
});

app.use(globalErrorHandler);

module.exports = app;

