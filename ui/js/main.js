let canCheck = false;

function copyText(text) {
	var copyFrom = $("<textarea/>")
	copyFrom.text(text)
	$("body").append(copyFrom)
	copyFrom.select()
	document.execCommand("copy")
	copyFrom.remove()
}

$(function() {
    $(".close-btn").click(function(){
        $("body").fadeOut()
        $.post(`https://${GetParentResourceName()}/close`)
    })

    $("#copyBtn").click(function(){
        copyText($("#your-code").val())
        showCopy()

        setTimeout(function(){
            hidePop()
        }, 1000)
    })

    $("#getOneBtn").click(function(){
        showLoading()

        $.post(`https://${GetParentResourceName()}/getCode`, function(response){
            refreshPrizes()
            let code = response
            $("#your-code").val(code)
            
            $("#enter-wrapper").hide()
            $("#create-wrapper").show()
            $("#create-wrapper").css("display", "flex")
            hidePop()
        })
    })

    $(document).on("click", ".prize-box", function(){
        let index = $(this).data("index")
        $.post(`https://${GetParentResourceName()}/getPrize`, JSON.stringify(index), function(response){
            refreshPrizes()

            if (response){
                showSuccess(response)

                setTimeout(() => {
                    hidePop()
                }, 1000);
            }else{
                showFail()

                setTimeout(() => {
                    hidePop()
                }, 1000);
            }
        })
    })

    window.addEventListener("message", function(e){
        data = e.data;
        action = data.action;

        if (action == "openUseMenu"){
            $("#create-wrapper").hide()
            $("#enter-wrapper").show()
            $("#enter-wrapper").css("display", "flex")
            $("body").fadeIn()
        }

        if (action == "openCodeMenu"){
            refreshPrizes()
            let code = data.code
            $("#your-code").val(code)
            
            $("#enter-wrapper").hide()
            $("#create-wrapper").show()
            $("#create-wrapper").css("display", "flex")
            $("body").fadeIn()
        }
    })

    $(document).on("keyup", "#code-input", function(){
        let text = $(this).val();
        let btn = $("#check-btn");

        if (text == ""){
            $(btn).addClass("disabled");
            canCheck = false
        }else{
            $(btn).removeClass("disabled");
            canCheck = true
        }
    })

    $(document).on("click", "#check-btn", function(){
        let code = $("#code-input").val()
        showLoading()

        if (canCheck){
            $.post(`https://${GetParentResourceName()}/useCode`, JSON.stringify(code), function(cb){
                hidePop()

                if (cb){
                    setTimeout(() => {
                        showTrue()

                        setTimeout(() => {
                            hidePop()
                            $("body").fadeOut()
                            $.post(`https://${GetParentResourceName()}/close`)
                        }, 1000);
                    }, 300);
                }else{
                    setTimeout(() => {
                        showFalse()

                        setTimeout(() => {
                            hidePop()
                        }, 1000);   
                    }, 300);
                }
            })
        }
    })
})

function showLoading() {
    $(".popup").show()
    $(".loading").fadeIn(200)
}

function showTrue() {
    $(".popup").show()
    $(".truePop").fadeIn(200)
}

function showFalse() {
    $(".popup").show()
    $(".falsePop").fadeIn(200)
}

function showFail() {
    $(".popup").show()
    $(".failPop").fadeIn(200)
}

function showSuccess(prize) {
    $(".successPop .text").text("Successfully taken $" + prize.amount)
    $(".popup").show()
    $(".successPop").fadeIn(200)
}

function showCopy(prize) {
    $(".popup").show()
    $(".copyPop").fadeIn(200)
}

function hidePop() {
    $(".pop").fadeOut(200)
    $(".popup").fadeOut(200);
}

function refreshPrizes() {
    $.post(`https://${GetParentResourceName()}/getGifts`, function(response){
        let gifts = response.prizes
        let html = ""

        gifts.forEach((gift, index) => {
            let taken = response.taken[index] == index + 1 ? true : false  

            console.log(taken, response.taken[index])
            
            if (response.uses > index) {
                html += `
                <div class="prize-box ${taken ? "disabled" : ""}" data-index="${index+1}">
                    <div class="id">#${index+1}</div>
                    <div class="text">${gift.title}</div>
                    <div class="img"><img src="assets/items/${gift.img}"></div>
                    <div class="btn">${taken ? "TAKEN" : "Take"}</div>
                </div>`
            }else{
                html += `
                <div class="prize-box disabled" data-index="${index+1}">
                    <div class="id">#${index+1}</div>
                    <div class="text">${gift.title}</div>
                    <div class="img"><img src="assets/items/${gift.img}"></div>
                    <div class="btn">GET</div>
                </div>`
            }
        });
        $(".prize-wrapper").html(html)
    })
}