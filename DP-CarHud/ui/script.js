$(document).ready(function () {
    window.addEventListener('message', function (event) {
        var data = event.data;

        if (data.toggle == true) {
            // Manejo de velocidad
            if (data.vel == undefined) {
                $('.vel').html('   ');
            } else if (data.vel <= 9) {
                $('.vel').html('  ' + data.vel);
            } else if (data.vel >= 10 && data.vel <= 99) {
                $('.vel').html(' ' + data.vel);
            } else if (data.vel >= 100) {
                $('.vel').html(data.vel);
            }

            // Actualizar el nivel de combustible
            $('#fuel').html(data.fuel + 'L');
            $('.fuel').css('color', 'black');

            // Cambiar el fondo del combustible según el nivel
            if (data.fuel <= 10) {
                $('.fuel').css('background-color', 'red');
            } else if (data.fuel <= 20) {
                $('.fuel').css('background-color', 'orange');
            } else if (data.fuel <= 30) {
                $('.fuel').css('background-color', 'yellow'); // Color de fondo
            } else if (data.fuel <= data.config) {
                $('.fuel').css('background-color', 'white'); // Color de fondo para menos de 50
            } else if (data.fuel >= data.config) {
                $('.fuel').css('background-color', 'transparent');
                $('.fuel').css('color', 'transparent');
                $('.fuel').css('box-shadow', 'none');
                $('.fuel').css('border', 'none');
            }

            // Manejar la visibilidad del velocímetro y la unidad km/h
            if (data.vel < 1) {
                $('.vel').fadeOut(750); // Ocultar velocímetro con 750ms
                $('.kmh').fadeOut(750); // Ocultar unidad km/h con 750ms
                $('.fuel').fadeOut(750); // Ocultar combustible con 750ms
            } else {
                $('.vel').fadeIn(750); // Mostrar velocímetro con 750ms
                $('.kmh').fadeIn(750); // Mostrar unidad km/h con 750ms
                $('.fuel').fadeIn(750); // Mostrar combustible con 750ms
            }

            $('.kmh').html(data.type);
            $('.carhud-container').fadeIn(750); // Mostrar el contenedor con 750ms
        } else {
            $('.carhud-container').fadeOut(750); // Ocultar el contenedor con 750ms
        }
    });
});
