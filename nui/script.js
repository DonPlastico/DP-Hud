$(() => {
    window.addEventListener("message", (event) => {
        let e = event.data;

        if (e.action === "u-hud") {
            // 1. Lógica de actualización de ANCHOS (CSS)
            $("#health").css({ "width": Math.round(e.vida) + "%" });
            $("#hunger").css({ "width": Math.round(e.hunger) + "%" });
            $("#thirst").css({ "width": Math.round(e.thirst) + "%" });
            $("#shield").css({ "width": Math.round(e.escudo) + "%" });
            $("#stamina").css({ "width": Math.round(e.stamina) + "%" });
            $("#oxygen").css({ "width": Math.round(e.oxigeno) + "%" });

            // 2. Lógica de visibilidad (MOVIDA Y ANIDADA AQUÍ)
            // ESTO SÓLO SE EJECUTA SI LLEGA EL MENSAJE "u-hud" CON LOS VALORES
            if (e.vida > 90) {
                // Solo ocultar si está visible
                if ($('.health').is(':visible')) {
                    $('.health').hide(200);
                }
            } else {
                // Solo mostrar si está oculto
                if ($('.health').is(':hidden')) {
                    $('.health').show(200);
                }
            };

            if (e.escudo <= 1) {
                if ($('.shield').is(':visible')) {
                    $('.shield').hide(200);
                }
            } else {
                if ($('.shield').is(':hidden')) {
                    $('.shield').show(200);
                }
            };

            if (e.hunger >= 80) {
                if ($('.hunger').is(':visible')) {
                    $('.hunger').hide(200);
                }
            } else {
                if ($('.hunger').is(':hidden')) {
                    $('.hunger').show(200);
                }
            };

            if (e.thirst >= 80) {
                if ($('.thirst').is(':visible')) {
                    $('.thirst').hide(200);
                }
            } else {
                if ($('.thirst').is(':hidden')) {
                    $('.thirst').show(200);
                }
            };

            if (e.stamina >= 100) {
                if ($('.stamina').is(':visible')) {
                    $('.stamina').hide(200);
                }
            } else {
                if ($('.stamina').is(':hidden')) {
                    $('.stamina').show(200);
                }
            };

            if (e.oxigeno >= 100) {
                if ($('.oxygen').is(':visible')) {
                    $('.oxygen').hide(200);
                }
            } else {
                if ($('.oxygen').is(':hidden')) {
                    $('.oxygen').show(200);
                }
            };
        }

        // Actualizar el Street Label y la Brújula:
        if (e.action === "updateStreetLabel") {
            $("#street-name").text(e.street);
            $("#compass-direction").text(e.direction);
        }

        // Control para el borde del minimapa y el Street Label:
        if (e.action === "toggleMinimapBorder") {
            if (e.show) {
                $('#minimap-elements-container').fadeIn(200);
            } else {
                $('#minimap-elements-container').fadeOut(200);
            }
        }

        // Aquí va el control de las barras de cine:
        if (e.action === "toggleCineBars") {
            if (e.show) {
                $("#cine-bar-top, #cine-bar-bottom").show(); // Mostrar primero
                setTimeout(() => {
                    $("#cine-bar-top").addClass("cine-visible");
                    $("#cine-bar-bottom").addClass("cine-visible");
                }, 10);
            } else {
                $("#cine-bar-top").removeClass("cine-visible");
                $("#cine-bar-bottom").removeClass("cine-visible");
                setTimeout(() => {
                    $("#cine-bar-top").hide();
                    $("#cine-bar-bottom").hide();
                }, 100);
            }
        }

        // Control para el Velocímetro, Marcha, Combustible y AHORA el Cinturón
        if (e.action === "updateVehicleHud") {
            const speed = Math.round(e.speed);
            const rpmPercent = Math.min(100, Math.round(e.rpm * 100));
            const fuelPercent = Math.round(e.fuel);

            // ------------------------------------------
            // 1. Lógica de Visibilidad Condicional
            // ------------------------------------------

            // Visibilidad del Velocímetro/HUD: Mostrar si la velocidad es >= 1 KPH
            let speedoVisible = false;
            if (speed >= 1) {
                speedoVisible = true;
            }

            // Visibilidad del Combustible (Secundaria): Mostrar solo si el combustible es 50% o menos
            let fuelVisibleCondition = false;
            if (fuelPercent <= 50) {
                fuelVisibleCondition = true;
            }

            // ------------------------------------------
            // 2. Comienzo de la Lógica de Actualización
            // ------------------------------------------

            // Actualiza la velocidad, RPM y marcha
            $("#speed-display").text(speed);
            const rpmBar = $("#rpm-bar");
            rpmBar.css({ "width": rpmPercent + "%" });
            if (rpmPercent >= 80) {
                rpmBar.css({ "background": "red" });
            } else {
                rpmBar.css({ "background": "white" });
            }
            $("#gear-display").text(e.gear);

            // Actualiza el texto del Combustible
            $("#fuel-display").text(fuelPercent + "%");

            // LÓGICA DE LA BARRA VERTICAL DE COMBUSTIBLE Y COLOR
            const fuelBarFill = $("#fuel-bar-fill");

            fuelBarFill.css({ "height": fuelPercent + "%" });

            // 💡 SOLUCIÓN 1: Declarar la variable fuelColor y darle un valor por defecto.
            let fuelColor = "white"; // Valor por defecto para > 50%

            if (fuelPercent <= 10) {
                fuelColor = "red";
            } else if (fuelPercent <= 20) {
                fuelColor = "orange";
            } else if (fuelPercent <= 30) {
                fuelColor = "yellow";
            } else if (fuelPercent <= 50) {
                // Ya tiene el valor "white" por defecto, pero lo dejamos explícito
                fuelColor = "white";
            }

            // 💡 SOLUCIÓN 2: APLICAR el color al elemento CSS
            // Esto es lo que faltaba: usar la variable fuelColor para cambiar el background.
            fuelBarFill.css({ "background-color": fuelColor });

            // 3.1. Visibilidad del Velocímetro (Depende de e.show Y la velocidad)
            if (e.show && speedoVisible) {
                $('#speedo-wrapper').fadeIn(200);
            } else {
                // Si e.show es false (te bajas) O speedoVisible es false (velocidad < 1)
                $('#speedo-wrapper').fadeOut(200);
            }

            // 3.2. Visibilidad del Combustible (Depende de e.show, speedoVisible Y fuelVisibleCondition)
            if (e.show && speedoVisible && fuelVisibleCondition) {
                $('#fuel-visual-wrapper').fadeIn(200);
            } else {
                $('#fuel-visual-wrapper').fadeOut(200);
            }

            // 3.3. Control de reseteo al salir del vehículo
            if (!e.show) {
                $('#speedo-wrapper').fadeOut(200);
                $('#fuel-visual-wrapper').fadeOut(200);
                $('#seatbelt-icon-wrapper').fadeOut(200);
                $('#limiter-icon-wrapper').fadeOut(200);
            }
        }

        if (e.action === "limiterStatus") {
            if (e.active === true) {
                // Muestra el icono si el limitador está ACTIVO
                $('#limiter-icon-wrapper').fadeIn(200);
            } else {
                // Oculta el icono si el limitador está DESACTIVO
                $('#limiter-icon-wrapper').fadeOut(200);
            }
        }

        if (e.action === "seatbeltStatus") {
            if (e.active === true) {
                // Muestra el icono si el cinturón está PUESTO
                $('#seatbelt-icon-wrapper').fadeIn(200);
            } else {
                // Oculta el icono si el cinturón está QUITADO
                $('#seatbelt-icon-wrapper').fadeOut(200);
            }
        }
    });
});