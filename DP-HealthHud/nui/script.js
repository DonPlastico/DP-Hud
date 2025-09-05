$(() => {
    window.addEventListener("message", (event) => {
        let e = event.data;

        if (e.action === "u-hud") {
            $("#health").css({ "width": Math.round(e.vida) + "%" });
            $("#hunger").css({ "width": Math.round(e.hunger) + "%" });
            $("#thirst").css({ "width": Math.round(e.thirst) + "%" });
            $("#shield").css({ "width": Math.round(e.escudo) + "%" });
            $("#stamina").css({ "width": Math.round(e.stamina) + "%" });
            $("#oxygen").css({ "width": Math.round(e.oxigeno) + "%" });
        }

        if (e.vida > 90) {
            $('.health').hide(200)
        } else {
            $('.health').show(200)
        };

        if (e.escudo <= 1) {
            $('.shield').hide(200)
        } else {
            $('.shield').show(200)
        };

        if (e.hunger >= 80) {
            $('.hunger').hide(200)
        } else {
            $('.hunger').show(200)
        };

        if (e.thirst >= 80) {
            $('.thirst').hide(200)
        } else {
            $('.thirst').show(200)
        };

        if (e.stamina >= 100) {
            $('.stamina').hide(200)
        } else {
            $('.stamina').show(200)
        };

        if (e.oxigeno >= 100) {
            $('.oxygen').hide(200)
        } else {
            $('.oxygen').show(200)
        };

        // Aquí va el control de las barras de cine:
        if (e.action === "toggleCineBars") {
            if (e.show) {
                $("#cine-bar-top, #cine-bar-bottom").show(); // Mostrar primero
                // Forzar reflow antes de añadir la clase para que la transición funcione
                setTimeout(() => {
                    $("#cine-bar-top").addClass("cine-visible");
                    $("#cine-bar-bottom").addClass("cine-visible");
                }, 10); // 10ms es suficiente
            } else {
                $("#cine-bar-top").removeClass("cine-visible");
                $("#cine-bar-bottom").removeClass("cine-visible");
                setTimeout(() => {
                    $("#cine-bar-top").hide();
                    $("#cine-bar-bottom").hide();
                }, 1000); // igual al tiempo de la transición
            }
        }
    });
});