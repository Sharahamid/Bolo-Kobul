import $ from "jquery";

$(function () {
    $(".bk-request-slider").slick({
        speed: 300,
        slidesToShow: 3,
        slidesToScroll: 3,
        infinite: false,
        responsive: [
            {
                breakpoint: 2000,
                settings: {
                    slidesToShow: 3,
                    slidesToScroll: 3,
                    variableWidth: true,
                    infinite: false
                }
            },
            {
                breakpoint: 1024,
                settings: {
                    slidesToShow: 3,
                    slidesToScroll: 3,
                    variableWidth: true,
                    infinite: false
                }
            },
            {
                breakpoint: 600,
                settings: {
                    slidesToShow: 2,
                    slidesToScroll: 2,
                    variableWidth: true,
                    infinite: false
                }
            },
            {
                breakpoint: 480,
                settings: {
                    slidesToShow: 1,
                    variableWidth: true,
                    slidesToScroll: 1,
                    infinite: false
                }
            }
            // You can unslick at a given breakpoint now by adding:
            // settings: "unslick"
            // instead of a settings object
        ]

    });
});