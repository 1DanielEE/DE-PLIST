Config = {}

-- 10 System --
Config.ActivePlayers ={
    ["police"] = {
        NoTag = "No Tag",
        NoRank = "Officer",
        title = "Active Officers",
        Authorized = {11,10,9,8,7,6,12},
        SpecialCallSigns = {
            {
                callsign = {min = "280", max = "289"},
                style = "detective"
            },
            {
                callsign = {min = "290", max = "299"}, 
                style = "swat"
            },
            {
                callsign = {min = "200", max = "208"}, 
                style = "command"
            },
            {
                callsign = {min = "300", max = "310"}, 
                style = "trooper"
            },
            {
                callsign = {min = "350", max = "360"},
                style = "ranger"
            },
            {
                callsign = {min = "400", max = "420"}, 
                style = "bcso"
            }
        }
    },
    ["ambulance"] = {
        NoTag = "No Tag",
        NoRank = "EMS",
        title = "Active EMS",
        Authorized = {4,5,6,7,8},
        SpecialCallSigns = {
            {
                callsign = {min = "100", max = "207"}, 
                style = "command"
            },
        }
    },
    ["corrections"] = {
        NoTag = "No Tag",
        NoRank = "Corrections",
        title = "Active Corrections",
        Authorized = {3,4,5},
        SpecialCallSigns = {
            {
                callsign = {min = "100", max = "102"}, 
                style = "command"
            },
            {
                callsign = {min = "103", max = "108"}, 
                style = "ranger"
            }
        }
    },
}
