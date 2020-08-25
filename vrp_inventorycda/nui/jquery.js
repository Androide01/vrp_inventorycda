$(document).ready(function(){
	var actionContainer = $("#actionmenu");
	window.addEventListener("message",function(event){
		switch(event.data.action){
			case "showMenu":
				updateMochila();
				actionContainer.fadeIn(400);
			break;

			case "hideMenu":
				actionContainer.fadeOut(400);
			break;

			case "updateMochila":
				updateMochila();
			break;

			

		}
	});

	document.onkeyup = function(data){
		if (data.which == 27){
			$.post("http://vrp_inventory/invClose");
		}
	};
});

const updateDrag = () => {
	$('.item').draggable({
		helper: 'clone',
		appendTo: 'body',
		zIndex: 99999,
		revert: 'invalid',
		opacity: 0.5,
		start: function(event,ui){
			$(this).children().children('img').hide();
			itemData = { key: $(this).data('item-key'), type: $(this).data('item-type') };
			if (itemData.key === undefined || itemData.type === undefined) return;

			let $el = $(this);
			$el.addClass("active");
			document.getElementById('invright').style.display = 'block';

		},
		stop: function(){
			$(this).children().children('img').show();

			let $el = $(this);
			$el.removeClass("active");
			document.getElementById('invright').style.display = 'none';

		}
	})

	$('.item-near').draggable({
		helper: 'clone',
		appendTo: 'body',
		zIndex: 99999,
		revert: 'invalid',
		opacity: 0.5,
		start: function(event,ui){
			$(this).children().children('img').hide();
			itemData = { key: $(this).data('item-key'), type: $(this).data('item-type') };

			if (itemData.key === undefined || itemData.type === undefined) return;

			let $el = $(this);
			$el.addClass("active");
		},
		stop: function(){
			$(this).children().children('img').show();

			let $el = $(this);
			$el.removeClass("active");
		}
	})

	$('.item-armado').draggable({
		helper: 'clone',
		appendTo: 'body',
		zIndex: 99999,
		revert: 'invalid',
		opacity: 0.5,
		start: function(event,ui){
			$(this).children().children('img').hide();
			itemData = { key: $(this).data('item-key'), type: $(this).data('item-type'), tDrop: $(this).data('item-drop') };

			if (itemData.key === undefined || itemData.type === undefined || itemData.tDrop === undefined ) return;

			let $el = $(this);
			$el.addClass("active");
		},
		stop: function(){
			$(this).children().children('img').show();

			let $el = $(this);
			$el.removeClass("active");
		}
	})

	$('.use').droppable({
		hoverClass: 'hoverControl',
		drop: function(event,ui){
			itemData = { key: ui.draggable.data('item-key'), type: ui.draggable.data('item-type') };

			if (itemData.key === undefined || itemData.type === undefined) return;

			$.post("http://vrp_inventory/useItem", JSON.stringify({
				item: itemData.key,
				type: itemData.type,
				amount: Number($("#amount").val())
			}))

			document.getElementById("amount").value = "";
		}
	})

	$('.send').droppable({
		hoverClass: 'hoverControl',
		drop: function(event,ui){
			itemData = { key: ui.draggable.data('item-key') };

			if (itemData.key === undefined) return;

			$.post("http://vrp_inventory/sendItem", JSON.stringify({
				item: itemData.key,
				amount: Number($("#amount").val())
			}))

			document.getElementById("amount").value = "";
		}
	})

	$('.drop').droppable({
		hoverClass: 'hoverControl',
		drop: function(event,ui){
			itemData = { key: ui.draggable.data('item-key') };

			if (itemData.key === undefined) return;

			$.post("http://vrp_inventory/dropItem", JSON.stringify({
				item: itemData.key,
				amount: Number($("#amount").val())
			}))

			document.getElementById("amount").value = "";
		}
	})




	$('#invleft').droppable({
		hoverClass: 'hoverControl',
		accept: '.item-armado, .item-near',
		drop: function(event,ui){
			itemData = { key: ui.draggable.data('item-key'), tDrop: ui.draggable.data('item-drop') };

			if (itemData.key === undefined || itemData.tDrop === undefined) return;
			$.post("http://vrp_inventory/DoSomething", JSON.stringify({
				tDrop: itemData.tDrop,
				item: itemData.key,
				amount: Number($("#amount").val())
			}))

			document.getElementById("amount").value = "";
		}
	})
}

const formatarNumero = (n) => {
	var n = n.toString();
	var r = '';
	var x = 0;

	for (var i = n.length; i > 0; i--) {
		r += n.substr(i - 1, 1) + (x == 2 && i != 1 ? '.' : '');
		x = x == 2 ? 0 : x + 1;
	}

	return r.split('').reverse().join('');
}

const updateMochila = () => {
	document.getElementById("amount").value = ""
	$.post("http://vrp_inventory/requestMochila",JSON.stringify({}),(data) => {
		const nameList = data.inventario.sort((a,b) => (a.name > b.name) ? 1: -1);
		console.log(data.slots)
		$('#invleft').empty().append(`
			${nameList.map((item) => (`
				<div class="slot">
                  	<div class="item" data-item-key="${item.key}" data-item-type="${item.type}" data-name-key="${item.name}">
                     	<img class="image" src="images/${item.index}.png"></div>
                     	<div class="quantity">${formatarNumero(item.amount)}
					</div>
				</div>
			`)).join('')}
		`);
		for (let i = 0; i < data.slots; i++) {
			
			$("#invleft").append(`
				<div class="slot">
				</div>
			`)
		}
		$('#d-peso').html(`
			<div id="peso2" ><div class='esquerdatopo'>PESO:</div> <div id="livrefundo" ><span id="livre"" ></span></div> <div id="direitatopo"><div class='datapeso'>${data.peso}</div><div class="datamaxpseo">/${data.maxpeso.toFixed(1)}</div></div></div><br><br>

		`);

		if(data.maxpeso == 6){
			$('#livre').css('width',data.peso/0.06+'%');
		  }else{
			$('#livre').css('width',data.peso/0.9+'%');
		  }
		$('#invright').html(`
			<div class="use">
			<div class="margin-to-class"><img src="https://cdn.discordapp.com/attachments/745069439195545720/745422782573314128/eating.png" style="width: 40px; margin-top: -5px;"></div>
			</div>
			<div class="send">
			<div class="margin-to-class"><img src="https://cdn.discordapp.com/attachments/745069439195545720/745421493147795486/give.png" style="width: 40px; margin-top: -5px;"></div>
			</div>
			<div class="drop">
			   <div class="margin-to-class"><img src="https://cdn.discordapp.com/attachments/745069439195545720/745422560732119100/drop.png" style="width: 40px; margin-top: -5px;"></div>

			</div>
		`);
		updateDrag();
	});
}

window.addEventListener('message', (event) => {
	let data = event.data
	if(data.type == 'open') {
		const nome = data.nome + ' ' + data.sobrenome;
		const emprego = data.emprego;
		const carteira = data.carteira;
		const coins = data.coins;
		const banco = data.banco;
		const vip = data.vip;
		const id = data.id;
		const documento = data.documento;
		const idade = data.idade;
		const telefone = data.telefone;
		const multas = data.multas;
		const mypaypal = data.mypaypal;

		$('.emprego span').text(emprego);
		$('.nome span').text(nome);
		$('.carteira span').text('R$'+carteira);
		$('.coins span').text(coins);
		$('.banco span').text(banco);
		$('.vip span').text(vip);
		$('.identidade span').text(id);
		$('.documento span').text(documento);
		$('.idade span').text(idade);
		$('.telefone span').text(telefone);
		$('.multas span').text(multas);
		$('.mypaypal span').text(mypaypal);
		$('#identidadeId').fadeIn('fast');
	}
	
	if(data.type == 'close') {
		$('#identidadeId').fadeOut('slow');
	}
});

function botao() {
	$.post("http://vrp_inventory/invClose");
}