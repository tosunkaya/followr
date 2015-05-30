$(document).ready(function() {
	$('table #unfollow-btn').on('click', function() {
		username = $(this).parent('td').prev('td').prev('td').prev('td').prev('td').text()
		if (username) {
			$.ajax({
				url: '/unfollow',
				method: 'POST',
				data: { username: username },
			})
			.success(function() {
				alert('success!')
			})

		}
	});
})