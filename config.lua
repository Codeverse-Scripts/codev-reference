Config = {
    Framework = "qb", -- qb / esx
    Prefix = "CDV-", -- PREFIX OF THE CODE
    MySQL = "oxmysql", -- oxmysql / mysql-async  / ghmattimysql

    Gifts = {
        [1] = {
            amount = 1000, -- AMOUNT OF THE PRIZE
            title = "Money", -- TITLE OF THE PRIZE
            img = "money.png", -- IMAGE OF THE PRIZE
            item = "money",  -- ITEM OF THE PRIZE (NO NEED TO BE USE WITH MONEY)
            type = "money" -- TYPE OF THE PRIZE
        },
        [2] = {
            amount = 4,
            title = "Sandwich",
            img = "sandwich.png",
            item = "sandwich",
            type = "item"
        },
        [3] = {
            amount = 1,
            title = "Adder",
            img = "adder.png",
            item = "adder",
            type = "vehicle"
        },
    }
}