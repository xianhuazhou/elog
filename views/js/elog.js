$(function() {
    function getLatestTime() {
        return 0 + $('#logsHeader').next('tr').attr('data-rel');
    }

    function updateLogs(options) {
        data = {
            'time': getLatestTime(),
            'apps[]': options.current_apps,
            'hosts[]': options.current_hosts,
            'levels[]': options.current_levels
        }
        $.get('/newlogs', data, function(res){
            res = $.trim(res);
            if (res != '') {
                $('#logsHeader').after(res);
            }
        });
    }

    window.elog = function(options) {
        setInterval(function(){
            updateLogs(options);
        }, options.refresh_time);
    }

    $('#btnFilterLogs').click(function(e){
        e.preventDefault();
        $('#filterForm').attr('action', '/').submit();
    });

    $('#btnFilterTopLogs').click(function(e){
        e.preventDefault();
        $('#filterForm').attr('action', '/toplogs').submit();
    });
});
