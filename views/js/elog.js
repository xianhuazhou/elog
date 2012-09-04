$(function() {
    function getLatestTime() {
        return 0 + $('#logsHeader').next('tr').attr('data-rel');
    }

    function updateLogs() {
        $.get('/newlogs?time=' + getLatestTime(), function(res){
            $('#logsHeader').after(res);
        });
    }

    window.elog = function(options) {
        setInterval(function(){
            updateLogs();
        }, options.refresh_time);
    }
});
