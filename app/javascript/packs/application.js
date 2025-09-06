// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
require('jquery');
require("@rails/ujs").start();
require("@rails/activestorage").start();
require("channels");
// require('packs/custom');
// require("turbolinks").start();

// import $ from 'jquery';
import 'bootstrap';
import 'bootstrap/js/dist/tooltip';
import 'bootstrap/js/dist/popover';
import 'slick-carousel';
import 'bootstrap-slider';
import 'bootstrap-select';
import 'cropper';
import $ from 'jquery';
window.$ = window.jquery = $;

import 'packs/custom';
import 'packs/landing';
import 'packs/partner_request';
import 'packs/marriage_information';
import 'packs/marriage_profile';
import 'packs/family_details';
import 'packs/customer_supports';
import 'packs/market_place';

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// $(function () {
//     $(document).on('shown.bs.modal', function() {
//         console.log($('.selectpicker'));
//         $('.selectpicker').selectpicker();
//         console.log('run select');
//     });
// });
