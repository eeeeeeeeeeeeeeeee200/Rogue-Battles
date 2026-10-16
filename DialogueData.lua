local NPCDialogue = {}

NPCDialogue.Dialogues = {

	-- 1. NEW PLAYER (The Introduction / Lives = -1)
	["Aretim_NewPlayer"] = {
		{
			Text = "Welcome. I see another one of your kind has arrived. Your vessel has already been created. Do you have any questions, or shall we proceed?",
			Replies = {
				{ Text = "Who are you?", Next = 2 },
				{ Text = "Proceed.", Next = 5 }
			}
		},
		{
			Text = "I am Aretim, the current God of Death.",
			Replies = {
				{ Text = "What is my purpose?", Next = 3 },
				{ Text = "Proceed.", Next = 5 }
			}
		},
		{
			Text = "Your ultimate purpose is to kill the Goddess of Life. She has long forgotten her purpose. I have crafted vessels for many beings like you so that you all may grow stronger to aid me in slaying her.",
			Replies = {
				{ Text = "...", Next = 4 }
			}
		},
		{
			Text = "That is enough information for now. I will give you your vessel and we shall proceed.",
			Replies = {
				{ Text = "Proceed.", Next = 5 }
			}
		},
		{
			Text = "Very well.",
			Next = nil
		}
	},

	-- 2. ALIVE (Talking to him mid-game / Lives > 0)
	["Aretim_Alive"] = {
		{
			Text = "Your vessel still has power. Is there something you need to ask me before I send you back?",
			Replies = {
				{ Text = "Send me back.", Next = 3 }, 
				{ Text = "I want a new vessel.", Next = 2 }
			}
		},
		{
			Text = "Your soul has already bonded with your form. A new vessel will be of the same kind. Do you still want that?",
			Replies = {
				{ Text = "Send me back as I am.", Next = 3 },
				{ Text = "Same kind?", Next = 5 },
				{ Text = "Make me a new vessel.", Next = 4 }
			}
		},
		{
			Text = "Very well.",
			Next = nil
		},
		{
			-- Dialogue 4 (New vessel / Reset)
			Text = "Very well.",
			Next = nil
		},
		{
			Text = "Yes. Your vessel will retain its previous nature; I cannot change that for now.",
			Replies = {
				{ Text = "Send me back as I am.", Next = 3 },
				{ Text = "Make me a new vessel.", Next = 4 }
			}
		},
	},

	-- 3. WIPED (When they have 0 lives and wipe)
	["Aretim_Wiped"] = {
		{
			Text = "Your previous vessel was turned to dust and your soul has returned to me. Shall we try again?",
			Replies = {
				{ Text = "I am ready.", Next = 2 },
				{ Text = "What happened to my old self?", Next = 3 }
			}
		},
		{
			Text = "Good. I shall forge you a new vessel.",
			Next = nil
		},
		{
			Text = "Your past self is dust. Forgotten. All that matters is the blade I am sharpening you into. Now, shall we try again?",
			Replies = {
				{ Text = "Proceed.", Next = 2 }
			}
		}
	},


	["Hugo"] = {
		{ -- dialogue 1
			Text = "Hello! Welcome to my coconut stand.",
			Replies = {
				{ Text = "I want to buy some.", Next = 2 },
				{ Text = "I thought I killed you.", Next = 3 }
			}
		},
		{ -- dialogue 2: the fees
			Text = "That'll be 20 Ember Shards.",
			Replies = {
				{ Text = "I'll take it.", Next = 4 },
				{ Text = "I'll pass.", Next = 5 }
			}
		},
		{ -- dialogue 3: mecha 
			Text = "Killed me? But we just met! I'm Hugo. I was once an inventor, but I gave up because I couldn't get the items I needed. Now, I just sell coconuts.",
			Replies = {
				{ Text = "So, can I buy a cup then?", Next = 2 }
			}
		},
		{ -- dialogue 4: buy
			Text = "Have a good day!",
			Next = nil
		},
		{ -- dialogue 5: dont buy
			Text = "That's okay.",
			Next = nil
		}
	},
	
	["Kab"] = {
		{ -- dialogue 1
			Text = "Wanna buy some corn?",
			Replies = {
				{ Text = "Sure.", Next = 2 },
				{ Text = "How do you cook them?", Next = 3 }
			}
		},
		{ -- dialogue 2: the fees
			Text = "It's 30 Ember Shards per cob.",
			Replies = {
				{ Text = "Buy.", Next = 4 },
				{ Text = "Changed my mind.", Next = 5 }
			}
		},
		{ -- dialogue 3: lava corn
			Text = "I use the lava, of course! It gives better results than using fire.",
			Replies = {
				{ Text = "How much for some corn?", Next = 2 }
			}
		},
		{ -- dialogue 4: buy
			Text = "Thanks!",
			Next = nil
		},
		{ -- dialogue 5: dont buy
			Text = "Don't forget to come back later!",
			Next = nil
		}
	},
	-- begin dialogue NEEDS to be step because idk how to do this better rn and im not gonna try ok
	["Gabriel1"] = {
		{ -- dialogue 1
			Text = "Welcome new soul. Shall we begin?",
			Replies = {
				{ Text = "Limbo.", Next = 3 }
			}
		},
		{ -- dialogue 2: begin, he teleports with the purest flash of light after talking very cool
			Text = "Follow me.",
			Next = nil
		},
		{ -- dialogue 3: limbo
			Text = "This is the place where all godly souls are sent to after being 'Destroyed' or created. We previously did not have access to this place, but now we can teach the new souls here.",
			Replies = {
				{ Text = "Soul.", Next = 4 },
			}
		},
		{ -- dialogue 4: the goddess will explain! (then aretim steals you from her)
			Text = "You will have your purpose explained to you by our goddess right after i teach you what you need to know, save your questions for later.",
			Replies = {
				{ Text = "Begin.", Next = 2 }
			}
		},

	},
	["Gabriel2"] = {
		{ -- dialogue 1
			Text = "First, we will have you dodge simple light magic, i will conjure light spirits to attack you, but dont worry, they are powerless against a soul with no vessel. ESCAPE or ATTACK them once you've practiced enough.",
			Replies = {
				{ Text = "Begin.", Next = 2 },
			}
		},
		{ -- dialogue 2: begin, lightspirit
			Text = "...",
			Next = nil
		},
	},
	["Gabriel3"] = {
		{ -- dialogue 1
			Text = "Very well, may we move on?",
			Replies = {
				{ Text = "Yes.", Next = 3 },
			}
		},
		{ -- dialogue 2: begin, lightspirit
			Text = "...",
			Next = nil
		},
		{ -- dialogue 3: idk yo
			Text = "As you are not a simple mortal being, you can learn more easily than others, with great mastery of just recently learned skills, and as such i have been ordered to teach new arrivals how to use the sword to get them started, here, take this blade and try it out on the dummy i placed there.",
			Replies = {
				{ Text = "...", Next = 4 },
			}
		},
		{ -- dialogue 4: idk yo
			Text = "You will be allowed to pick your own method of fighting after we finish here, do not worry, also worry not for the dummy, hit it as strong as you like.",
			Replies = {
				{ Text = "Understood.", Next = 2 },
			}
		},
	},
	
	["Gabriel4"] = {
		{ -- dialogue 1
			Text = "May we move on?",
			Replies = {
				{ Text = "Yes.", Next = 3 },
				{ Text = "I didn't fight.", Next = 4 },
			}
		},
		{ -- dialogue 2: walk
			Text = "...",
			Next = nil
		},
		{ -- dialogue 3: idk yo
			Text = "Just walk ahead to the end of this path, i will stay to teach the ones yet to arrive",
			Replies = {
				{ Text = "...", Next = 2 },
			}
		},
		{ -- dialogue 4: idk yo
			Text = "To me it does not matter. You will learn through defeat and redemption in real battles. May we move on?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "Wait.", Next = 5 },
			}
		},
		{ -- dialogue 5 wait from hit game platform battles
			Text = "...",
			Next = nil
		},
	},

	["Sergi"] = {
		{
			Text = "Hello, this is my forge, do you need anything?",
			Replies = {
				{ Text = "Quest.", Next = 5},
				{ Text = "Shield.", Next = 3},
				{ Text = "Helmet.", Next = 4},
				{ Text = "I'm fine.", Next = 2},
			}
		},
		{
			Text = "Goodbye.",
			Next = nil
		},
		{
			Text = "I am selling one, it's over there on the inside of my shop, feel free to take a look at it if you want.",
			Replies = {
				{ Text = "Got it.", Next = 2}
			}
		},
		{
			Text = "I have a very special helmet..., it's very precious to me so you'll need approval from my old friend Kaint if you intend on buying it.",
			Replies = {
				{ Text = "Got it.", Next = 2}
			}
		},
		{
			Text = "A quest huh? Well I do need more materials... Bring me 3 black rocks and in exchange I'll allow you to buy the most prized set in my shop.",
			Replies = {
				{ Text = "Got it.", Next = 6},
				{ Text = "Nevermind.", Next = 2}
			}
		},
		{
			Text = "Good luck.",
			Next = nil
		}
	},
	["SergiQuest"] = {
		{
			Text = "Did you get my rocks yet? I think I saw some elementals on the beach that had some...",
			Replies = {
				{ Text = "Got them.", Next = 2},
				{ Text = "Not yet.", Next = 3}
			}
		},
		{
			Text = "Let's see...",
			Next = nil
		},
		{
			Text = "It's okay, come back when you do.",
			Next = nil
		}
	},
	["SergiQuestDone"] = {
		{
			Text = "Hello, this is my forge, do you need anything?",
			Replies = {
				{ Text = "Shield.", Next = 3},
				{ Text = "Helmet.", Next = 4},
				{ Text = "I'm fine.", Next = 2},
			}
		},
		{
			Text = "Goodbye.",
			Next = nil
		},
		{
			Text = "I am selling one, it's over there on the wall, feel free to take a look at it if you want.",
			Replies = {
				{ Text = "Got it.", Next = 2}
			}
		},
		{
			Text = "I do have a helmet... it's on that anvil, however it's very precious to me so you'll need approval from my old friend Kaint to buy it.",
			Replies = {
				{ Text = "Got it.", Next = 2}
			}
		},
	},
	
	-- lancer
	["Dean"] = {
		{
			Text = "Ugh... I keep telling him the sky kingdom isnt underground... And yet, he keeps digging...",
			Replies = {
				{ Text = "I believe in him.", Next = 3},
				{ Text = "...", Next = 2},
			}
		},
		{
			Text = "Bye.",
			Next = nil
		},
		{
			Text = "Why?...",
			Replies = { Text = "Bye.", Next = 2}
		},
	},
	
	-- cool name
	["Ezra"] = {
		{
			Text = "This is troubling...",
			Replies = {
				{ Text = "What is?", Next = 3},
				{ Text = "Bye.", Next = 2},
			}
		},
		{
			Text = "See you...",
			Next = nil
		},
		{
			Text = "The slundra tribe is more active these past few days, but we dont know why... Well, at least staying close to the shopkeepers should be safe, they are quite strong.",
			Replies = { Text = "Bye.", Next = 2}
		},
	},
	
-- french croissant merci boku paris 
-- everybody gangsta in france until some moth guy in paris starts making villians
	["Benoit"] = {
		{
			Text = "Dig! Dig! To the center of the earth! The sky kingdom will be mine!",
			Replies = {
				{ Text = "I believe in you", Next = 3},
				{ Text = "...", Next = 2},
			}
		},
		{
			Text = "Dig! Dig! To the center of the earth!",
			Next = nil
		},
		{
			Text = "Merci stranger.",
			Replies = { Text = "Bye.", Next = 2}
		},
	},


	["Robbie"] = {
		{
			Text = "Maybe being blind isn't so bad. Even if the beach's ugly, I have no way to tell!",
			Replies = {
				{ Text = "Train me.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "You want a blind man to teach you? Well, I am still a warrior. Perhaps I could teach you the art of the sword...",
			Replies = {
				{ Text = "Learn.", Next = 4 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "See ya.",
			Next = nil
		},
		{
			Text = "You know, there's this guy Hugo who sells drinks here at the beach. It's hard for me to get there, but when I do, I want to be able to afford some drinks! I'll teach you what I know for 20 Ember Shards.",
			Replies = {
				{ Text = "Learn.", Next = 5 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
		},
	},

	["TestDungeonNpc"] = {
		{
			Text = "Start a dungeon with your party?",
			Replies = {
				{ Text = "For sure.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "Okay bye!",
			Next = nil
		},
	},
	
	["RobbieLearning"] = {
		{
			Text = "I can teach you more for 20 Ember Shards.",
			Replies = {
				{ Text = "Train me.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "See ya.",
			Next = nil
		},
	},

	["Robbie_NoSword"] = {
		{
			Text = "If you want to train with me, you'll need a sword. Consider yourself lucky, it just so happens im selling mine!",
			Replies = {
				{ Text = "Goodbye.", Next = 2 },
			}
		},
		{
			Text = "See ya.",
			Next = nil
		}
	},
	
	["Robbie_Trained"] = {
		{
			Text = "I can feel your strength. You will surely make it far in this world.",
			Replies = {
				{ Text = "Goodbye.", Next = 2 },
			}
		},
		{
			Text = "See ya.",
			Next = nil
		}
	},
	
	["Robbie_WrongClass"] = {
		{
			Text = "Ah... how nice...",
			Replies = {
				{ Text = "...", Next = 2 },
			}
		},
		{
			Text = "...",
			Next = nil
		}
	},


	["Noelle"] = {
		{
			Text = "Hey, wanna learn how to hunt with a spear?",
			Replies = {
				{ Text = "Learn.", Next = 3 },
				{ Text = "Goodbye.", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "Bye then.",
			Next = nil
		},
		{
			--dialogue 3: the fees
			Text = "Alright. It will cost you a small fee of 60 Ember Shards. I'll teach you how to wield a spear, but you'll have to either buy this one next to me or bring your own next time.",
			Replies = {
				{ Text = "Learn.", Next = 4 },
				{ Text = "No.", Next = 2 }
			}

		},
		-- dialogue 4: Check requirements and give class
		{Text = "...",
			Next = nil
		}
	},

	["NoelleLearning"] = {
		{
			Text = "I can teach you more for a mere 60 Ember Shards.",
			Replies = {
				{ Text = "Train me.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "Bye.",
			Next = nil
		},
	},
	
	["NoelleNotLearning"] = {
		{
			Text = "I can't teach you any more if you don't have a spear.",
			Replies = {
				{ Text = "...", Next = 2 },
			},
		},
		{
			Text = "...",
			Next = nil
		},
	},

	["Noelle_Trained"] = {
		{
			Text = "Thanks for the shards. Thats all I can teach you.",
			Replies = {
				{ Text = "Goodbye.", Next = 2 },
			}
		},
		{
			Text = "Bye.",
			Next = nil
		}
	},
	
	["Noelle_WrongClass"] = {
		{
			Text = "What do you want?",
			Replies = {
				{Text = "Train.", Next = 3},
				{ Text = "Goodbye.", Next = 2 },
			}
		},
		{
			Text = "Bye.",
			Next = nil
		},
		{
			Text = "You are not fit for my teachings.",
			Next = nil
		}
	},
	
	-- from hit anime brawl star
	["Edgar"] = {
		{
			Text = "Hey... Do you... Do you want to… learn some moves?",
			Replies = {
				{ Text = "I do.", Next = 3 },
				{ Text = "Goodbye.", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "I'll be WAITING for you.",
			Next = nil
		},
		{
			--dialogue 3: the fees
			Text = "Get me some shards... SHARDS! and then WE CAN TALK!. Let's do 60, no, 120... SHARDS!.",
			Replies = {
				{ Text = "Learn.", Next = 4 },
				{ Text = "No.", Next = 2 }
			}

		},
		-- dialogue 4: Check requirements and give class
		{Text = "...",
			Next = nil
		}
	},

	["EdgarLearning"] = {
		{
			Text = "120 shards...",
			Replies = {
				{ Text = "Train.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "hah AHAHAHA.",
			Next = nil
		},
	},

	["EdgarNotLearning"] = {
		{
			Text = "You need a SPEAR you FOOL.",
			Replies = {
				{ Text = "...", Next = 2 },
			},
		},
		{
			Text = "...",
			Next = nil
		},
	},

	["Edgar_Trained"] = {
		{
			Text = "The plants... They took... Them...",
			Replies = {
				{ Text = "...", Next = 2 },
			}
		},
		{
			Text = "...",
			Next = nil
		}
	},

	["Edgar_WrongClass"] = {
		{
			Text = "Have you… seen... Them...?",
			Replies = {
				{ Text = "...", Next = 2 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	["Jin"] = {
		{
			Text = "...",
			Replies = {
				{ Text = "Temple.", Next = 3 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "...",
			Next = nil
		},

		{
			--dialogue 3: temple
			Text = "This is one of the ancient temples, we do research in there, mostly based around souls.",
			Replies = {
				{ Text = "Enter.", Next = 4 },
				{ Text = "Goodbye.", Next = 2 }
			}

		},
		-- dialogue 4: evil temple
		{
			
			Text = "So you're the one Grim mentioned, godly soul, he said we could experiment on you, but i'll tell you this. You're probably not living any of the experiments, and if you do... nevermind. If you truly want to participate just for some rewards, talk to Rin over there.",
			Replies = {
				{ Text = "Experiments.", Next = 5 },
				{ Text = "Goodbye.", Next = 2 }
			}

		},

		{
			--dialogue 5: experiments
			Text = "Most of the experiments we will perform will be simple battles against soul powered mechs, but there may be some more dificult tests... if you really want to stand a chance, i advise you to bring a party with you.",
			Replies = {
				{ Text = "...", Next = 2 }
			}

		},
	},
	
	["JinRecruit"] = {
		{
			Text = "...",
			Replies = {
				{ Text = "Temple.", Next = 3 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "...",
			Next = nil
		},

		{
			--dialogue 3: temple
			Text = "This is one of the ancient temples, we do research in there, mostly based around souls.",
			Replies = {
				{ Text = "Enter.", Next = 4 },
				{ Text = "Goodbye.", Next = 2 }
			}

		},
		-- dialogue 4: evil temple
		{

			Text = "So you're the one Grim mentioned, godly soul, he said we could experiment on you, but i'll tell you this. You're probably not living any of the experiments... Although your soul seems strong... If you truly want to participate just for some rewards, talk to Rin over there.",
			Replies = {
				{ Text = "Experiments.", Next = 5 },
				{ Text = "Soul.", Next = 6},
				{ Text = "Goodbye.", Next = 2 }
			}

		},

		{
			--dialogue 5: experiment
			Text = "Most of the experiments we will perform will be simple battles against soul powered mechs, but there may be some more dificult tests... if you really want to stand a chance, i advise you to bring a party with you.",
			Replies = {
				{ Text = "Train me.", Next = 3 },
				{ Text = "...", Next = 2 }
			}

		},
		{
			--dialogue 6: class
			Text = "Yes... Your soul seems strong, perhaps i could teach you some things to help you survive in there, but only if you manage to get past the first experiment.",
			Replies = {
				{ Text = "...", Next = 2 }
			}

		},
		
	},
	
	-- fish in the volcano hotlands undyne ahhhh orat but anti racist :sunglasses:
	["Faye"] = {
		{
			Text = "...",
			Replies = {
				{ Text = "Train me.", Next = 3 },
				{ Text = "What are you doing?", Next = 5 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "...",
			Next = nil
		},
		
		{
			--dialogue 3: you need 35 max health to get the class
			Text = "Train you? Well, teaching others is the best way to learn... I'll teach you for cheap, but only if you have enough endurance to endure it.",
			Replies = {
				{ Text = "Learn.", Next = 4 },
				{ Text = "No.", Next = 2 }
			}

		},
		-- dialogue 4: Check requirements and give class
		{Text = "...",
			Next = nil
		},

		{
			--dialogue 5: fish, you know what that means!
			Text = "The people of my race aren't built to handle heat. I am training to break my limits.",
			Replies = {
				{ Text = "Train me.", Next = 3 },
				{ Text = "...", Next = 2 }
			}

		},
		
	},
	
	["Faye_Trained"] = {
		{
			Text = "...",
			Next = nil,
		},
	},
		
		
	["FayeLearning"] = {
		{
			Text = "I'll teach you more for 20 Ember Shards.",
			Replies = {
				{ Text = "Learn.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	--Defender Trainer
	["Kaint_Other"] = {
		{
			Text = "I love training, you should try it too sometime...",
			Replies = {
				{ Text = "Why?", Next = 2},
				{ Text = "Goodbye.", Next = 3 },
			},
		},
		{
			Text = "You have to become strong enough if you want to protect what is dear to you...",
			Replies = {
				{ Text = "Train me.", Next = 4},
				{ Text = "I guess.", Next = 3 }
			}
		},
		{
			Text = "Goodbye.",
			Next = nil
		},
		{
			Text = "I'm afraid your current self is leaning more towards destruction than protecting your allies, I can't teach you anything.",
			Next = nil
		}
	},
	["Kaint_Recruit"] = {
		{
			Text = "I see you want to protect your allies, I like you, I'll train you if you allow me to.",
			Replies = {
				{ Text = "Learn.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "Very well, I won't ask you for money, I simply want you to keep protecting everyone.",
			Next = nil
		},
		{
			Text = "Come back if you change your mind...",
			Next = nil
		}
	},
	["Kaint_Learning"] = {
		{
			Text = "You're doing well, do you want to learn more?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "Maybe later.", Next = 3 }
			}
		},
		{
			Text = "Wonderful.",
			Next = nil
		},
		{
			Text = "Come back when you're ready.",
			Next = nil
		}
	},
	["Kaint_Trained"] = {
		{
			Text = "I have nothing more to teach you. Goodbye.",
			Replies = {
				{ Text = "Goodbye.", Next = 2 },
			}
		},
		{
			Text = "Farewell.",
			Next = nil
		}
	},
	
	-- straight man dont let keo say otherwise
	["Zylies"] = {
		{
			Text = "Greetings, young one. I see you have discovered the tree. Are you here to learn how to control energy better?",
			Replies = {
				{ Text = "Teach me.", Next = 3 },
				{ Text = "Tree.", Next = 5 },
				{ Text = "Scrolls.", Next = 7 },
				{ Text = "Bye.", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "May we meet again.",
			Next = nil
		},

		{
			-- dialogue 3: train
			Text = "Magic is easy to learn, but it is time consuming for most people, are you up for that?",
			Replies = {
				{ Text = "Learn.", Next = 4 },
				{ Text = "Let me think.", Next = 2 }
			}

		},
		-- dialogue 4: Check requirements and give class
		{Text = "...",
			Next = nil
		},

		{
			--dialogue 5: tree
			Text = "This is not an ordinary tree. It has been alive for ten thousand years. I came here looking for the extensive knowledge it holds, and it allowed me to live inside of it; as a kind of payment, I constructed a magical link that lets others talk to the tree.",
			Replies = {
				{ Text = "Talk.", Next = 6 },
				{ Text = "...", Next = 2 }
			}

		},
		{
			--dialogue 6: tree continuation
			Text = "Just go into the green beam of light up there; you will likely be allowed in.",
			Replies = {
				{ Text = "...", Next = 2 }
			}

		},
		{
			--dialogue 7: scrollable gems
			Text = "Do you have any magical items? i could use magic to modify them into scrolls.",
			Replies = {
				{ Text = "Scrolls.", Next = 8 },
				{ Text = "...", Next = 2 }
			}

		},
		{
			--dialogue 8: scrollable gems
			Text = "Very well.",
			Next = nil
			

		},
	},
	
	["ZyliesLearning"] = {
		{
			Text = "I'll teach you more for 40 Ember Shards.",
			Replies = {
				{ Text = "Learn.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	["Zylies_Trained"] = {
		{
			Text = "You have come a long way. I am proud of you.",
			Next = nil,
		},
	},
	
	["ZyliesWrongClass"] = {
		{
			Text = "Greetings, young one. I see you have discovered the tree.",
			Replies = {
				{ Text = "Teach me.", Next = 3 },
				{ Text = "Tree.", Next = 5 },
				{ Text = "Scrolls.", Next = 7 },
				{ Text = "Bye.", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "May we meet again.",
			Next = nil
		},

		{
			-- dialogue 3: train
			Text = "I am sorry, but you are incompatible with my teachings.",
			Replies = {
				{ Text = "...", Next = 2 }
			}

		},
		-- dialogue 4: Check requirements and give class
		{Text = "...",
			Next = nil
		},

		{
			--dialogue 5: tree
			Text = "This is not an ordinary tree. It has been alive for ten thousand years. I came here looking for the extensive knowledge it holds, and it allowed me to live inside of it; as a kind of payment, I constructed a magical link that lets others talk to the tree.",
			Replies = {
				{ Text = "Talk.", Next = 6 },
				{ Text = "...", Next = 2 }
			}

		},
		{
			--dialogue 6: tree continuation
			Text = "Just go into the green beam of light up there; you will likely be allowed in.",
			Replies = {
				{ Text = "...", Next = 2 }
			}

		},
		{
			--dialogue 7: scrollable gems
			Text = "Do you have any magical items? i could use magic to modify them into scrolls.",
			Replies = {
				{ Text = "Scrolls.", Next = 8 },
				{ Text = "...", Next = 2 }
			}

		},
		{
			--dialogue 8: scrollable gems
			Text = "Very well.",
			Next = nil


		},
	},
	
	-- the mother of all trees, including you
	["MotherTree"] = {
		{
			-- dialogue 1
			Text = "Greetings little seedling... What do you wish to inquire about?",
			Replies = {
				{ Text = "Knowledge", Next = 4 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "Can't make up your mind? That's alright. I'll be here if you have anything to ask.",
			Next = nil
		},

		{
			-- dialogue 3: end dialogue
			Text = "May we meet again.",
			Next = nil
		},

		{
			-- dialogue 4: KNOWLEDGE
			Text = "What kind of knowledge do you desire?",
			Replies = {
				{ Text = "Magic.", Next = 5 },
				{ Text = "Gods.", Next = 7 },
				{ Text = "Goal.", Next = 9 }, 
			}

		},
		-- dialogue 5: MAGIC
		{
			Text = "Magic? I'm sure you've seen it many times already. Even the weakest being can use magic if they desire to, but if you were to specialize in it... The things you could achieve... would be tremendous.",
			Replies = {
				{ Text = "Teach me.", Next = 6},
				{ Text = "...", Next = 2}
			}
		},

		-- dialogue 6: Druid of the jungle
		{
			Text = "I'm afraid I cannot teach someone unless they know how to control energy well. Maybe you could train with Zylies; if you do, I'll be able to teach you.",
			Replies = {
				{ Text = "...", Next = 3}
			}
		},

		{
			-- dialogue 7: GODS
			Text = "The Gods of this land... The ones that stand above all... You see, unlike what you might think, no one is born a God. The Gods themselves are simply chosen by their previous counterparts.",
			Replies = {
				{ Text = "God", Next = 10 },
				{ Text = "...", Next = 2 }
			}

		},
		
		{
			-- dialogue 8: Goddess
			Text = "I'm sorry, but even I have not lived long enough to learn much about her, although I can feel the balance of the universe slowly collapsing from her doings.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 9: GOAL
			Text = "The Goddess is breaking the balance... That's why Aretim sent you, is it not? Perhaps not just to slay her, but also... Ha ha... I hope you succeed. It would be something very interesting to watch.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 10: GOD
			Text = "What? do you intend to become a god yourself? Ha ha... now that would be interesting, wouldn't it?",
			Replies = {
				{ Text = "Goddess", Next = 8 },
				{ Text = "...", Next = 2 }
			}

		},
	},

	-- the mother of all trees, including you, but youre a wizard now.
	["MotherTreeWizard"] = {
		{
			-- dialogue 1
			Text = "Greetings little seedling... What do you wish to inquire about?",
			Replies = {
				{ Text = "Knowledge", Next = 4 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "Can't make up your mind? That's alright. I'll be here if you have anything to ask.",
			Next = nil
		},

		{
			-- dialogue 3: end dialogue
			Text = "May we meet again.",
			Next = nil
		},

		{
			-- dialogue 4: KNOWLEDGE
			Text = "What kind of knowledge do you desire?",
			Replies = {
				{ Text = "Magic.", Next = 5 },
				{ Text = "Gods.", Next = 7 },
				{ Text = "Goal.", Next = 9 }, 
			}

		},
		-- dialogue 5: MAGIC
		{
			Text = "Magic? I'm sure you've seen it many times already. Even the weakest being can use magic if they desire to, but if you were to specialize in it... The things you could achieve... would be tremendous.",
			Replies = {
				{ Text = "Teach me.", Next = 6},
				{ Text = "...", Next = 2}
			}
		},

		-- dialogue 6: Druid of the jungle
		{
			Text = "Very well, you've already learned how to control energy well. Perhaps you are fit for my teachings, However, you'll have to show your devotion to nature first...",
			Replies = {
				{ Text = "How?", Next = 11}
			}
		},

		{
			-- dialogue 7: GODS
			Text = "The Gods of this land... The ones that stand above all... You see, unlike what you might think, no one is born a God. The Gods themselves are simply chosen by their previous counterparts.",
			Replies = {
				{ Text = "God.", Next = 10 },
				{ Text = "...", Next = 2 }
			}

		},

		{
			-- dialogue 8: Goddess
			Text = "I'm sorry, but even I have not lived long enough to learn much about her, although I can feel the balance of the universe slowly collapsing from her doings.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 9: GOAL
			Text = "The Goddess is breaking the balance... That's why Aretim sent you, is it not? Perhaps not just to slay her, but also... Ha ha... I hope you succeed. It would be something very interesting to watch.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 10: GOD
			Text = "What? do you intend to become a god yourself? ha ha... that would be interesting, wouldn't it?",
			Replies = {
				{ Text = "Goddess.", Next = 8 },
				{ Text = "...", Next = 2 }
			}

		},
		{
			-- dialogue 11: Quest
			Text = "Ill show you the spirit of the forest. Once you have proven your worth, i shall teach you.",
			Replies = {
				{ Text = "Fight.", Next = 12 },
				{ Text = "Wait.", Next = 3 },

			}

		},
		{
			-- dialogue 12: Initiate Battle
			Text = "Very Well. ",
			Next = nil
		},
	},
	
	-- for all the little seedlings of the world
	["MotherTreeMekolkal"] = {
		{
			-- dialogue 1
			Text = "Greetings little seedling... What do you wish to inquire about?",
			Replies = {
				{ Text = "Knowledge", Next = 4 },
				{ Text = "Purification", Next = 11 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "Can't make up your mind? That's alright. I'll be here if you have anything to ask.",
			Next = nil
		},

		{
			-- dialogue 3: end dialogue
			Text = "May we meet again.",
			Next = nil
		},

		{
			-- dialogue 4: KNOWLEDGE
			Text = "What kind of knowledge do you desire?",
			Replies = {
				{ Text = "Magic.", Next = 5 },
				{ Text = "Gods.", Next = 7 },
				{ Text = "Goal.", Next = 9 }, 
			}

		},
		-- dialogue 5: MAGIC
		{
			Text = "Magic? I'm sure you've seen it many times already. Even the weakest being can use magic if they desire to, but if you were to specialize in it... The things you could achieve... would be tremendous.",
			Replies = {
				{ Text = "Teach me.", Next = 6},
				{ Text = "...", Next = 2}
			}
		},

		-- dialogue 6: Druid of the jungle
		{
			Text = "Very well, you've already learned how to control energy well. Perhaps you are fit for my teachings, However, you'll have to show your devotion to nature first...",
			Replies = {
				{ Text = "How?", Next = 15}
			}
		},

		{
			-- dialogue 7: GODS
			Text = "The Gods of this land... The ones that stand above all... You see, unlike what you might think, no one is born a God. The Gods themselves are simply chosen by their previous counterparts.",
			Replies = {
				{ Text = "God.", Next = 10 },
				{ Text = "...", Next = 2 }
			}

		},

		{
			-- dialogue 8: Goddess
			Text = "I'm sorry, but even I have not lived long enough to learn much about her, although I can feel the balance of the universe slowly collapsing from her doings.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 9: GOAL
			Text = "The Goddess is breaking the balance... That's why Aretim sent you, is it not? Perhaps not just to slay her, but also... Ha ha... I hope you succeed. It would be something very interesting to watch.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 10: GOD
			Text = "What? do you intend to become a god yourself? ha ha... that would be interesting, wouldn't it?",
			Replies = {
				{ Text = "Goddess.", Next = 8 },
				{ Text = "...", Next = 2 }
			}

		},
		{
			-- dialogue 11: PURIFICATION
			Text = "I see... Youre like me, a plant life form... but there is something corrupting you, other for the Soul controlling your body, that is. but thats the one im talking to, isnt it?",
			Replies = {
				{ Text = "Removal.", Next = 12 },
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 12: PURIFICATION
			Text = "I can remove it from you permanently, it will change you a little though. Do you want to proceed?",
			Replies = {
				{ Text = "Yes.", Next = 15 },
				{ Text = "No.", Next = 14 }
			}

		},
		{
			-- dialogue 13: ACCEPTANCE
			Text = "If you change your mind, come back to me.",
			Next = nil,

		},
		{
			-- dialogue 14: PURIFICATION
			Text = "I dont advise on it, but i suppose if youre so hesitant... perhaps you could also accept this path, be advised, however, that i wont help you with that.",
			Replies = {
				{ Text = "...", Next = 13 },
			}

		},
		{
			-- dialogue 15: PROCEED
			Text = "Very well.",
			Next = nil

		},
	},
	
	-- for all the little wizard seedlings of the world
	["MotherTreeWizardMekolkal"] = {
		{
			-- dialogue 1
			Text = "Greetings little seedling... What do you wish to inquire about?",
			Replies = {
				{ Text = "Knowledge", Next = 4 },
				{ Text = "Purification", Next = 11 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "Can't make up your mind? That's alright. I'll be here if you have anything to ask.",
			Next = nil
		},

		{
			-- dialogue 3: end dialogue
			Text = "May we meet again.",
			Next = nil
		},

		{
			-- dialogue 4: KNOWLEDGE
			Text = "What kind of knowledge do you desire?",
			Replies = {
				{ Text = "Magic.", Next = 5 },
				{ Text = "Gods.", Next = 7 },
				{ Text = "Goal.", Next = 9 }, 
			}

		},
		-- dialogue 5: MAGIC
		{
			Text = "Magic? I'm sure you've seen it many times already. Even the weakest being can use magic if they desire to, but if you were to specialize in it... The things you could achieve... would be tremendous.",
			Replies = {
				{ Text = "Teach me.", Next = 6},
				{ Text = "...", Next = 2}
			}
		},

		-- dialogue 6: Druid of the jungle
		{
			Text = "Very well, you've already learned how to control energy well. Perhaps you are fit for my teachings, However, you'll have to show your devotion to nature first...",
			Replies = {
				{ Text = "How?", Next = 15}
			}
		},

		{
			-- dialogue 7: GODS
			Text = "The Gods of this land... The ones that stand above all... You see, unlike what you might think, no one is born a God. The Gods themselves are simply chosen by their previous counterparts.",
			Replies = {
				{ Text = "God.", Next = 10 },
				{ Text = "...", Next = 2 }
			}

		},

		{
			-- dialogue 8: Goddess
			Text = "I'm sorry, but even I have not lived long enough to learn much about her, although I can feel the balance of the universe slowly collapsing from her doings.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 9: GOAL
			Text = "The Goddess is breaking the balance... That's why Aretim sent you, is it not? Perhaps not just to slay her, but also... Ha ha... I hope you succeed. It would be something very interesting to watch.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 10: GOD
			Text = "What? do you intend to become a god yourself? ha ha... that would be interesting, wouldn't it?",
			Replies = {
				{ Text = "Goddess.", Next = 8 },
				{ Text = "...", Next = 2 }
			}

		},
		{
			-- dialogue 11: PURIFICATION
			Text = "I see... Youre like me, a plant life form... but there is something corrupting you, other for the Soul controlling your body, that is. but thats the one im talking to, isnt it?",
			Replies = {
				{ Text = "Removal.", Next = 12 },
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 12: PURIFICATION
			Text = "I can remove it from you permanently, it will change you a little though. Do you want to proceed?",
			Replies = {
				{ Text = "Yes.", Next = 17 },
				{ Text = "No.", Next = 14 }
			}

		},
		{
			-- dialogue 13: ACCEPTANCE
			Text = "If you change your mind, come back to me.",
			Next = nil,

		},
		{
			-- dialogue 14: PURIFICATION
			Text = "I dont advise on it, but i suppose if youre so hesitant... perhaps you could also accept this path, be advised, however, that i wont help you with that.",
			Replies = {
				{ Text = "...", Next = 13 },
			}

		},
		{
			-- dialogue 15: Quest
			Text = "Ill show you the spirit of the forest. Once you have proven your worth, i shall teach you.",
			Replies = {
				{ Text = "Fight.", Next = 16 },
				{ Text = "Wait.", Next = 3 },

			}

		},
		{
			-- dialogue 16: Initiate Battle
			Text = "Very Well. ",
			Next = nil
		},
		{
			-- dialogue 17: PROCEED
			Text = "Very well.",
			Next = nil

		},
	},
	-- for all the maxed seedlings of the world
	["MotherTreeTrainedMekolkal"] = {
		{
			-- dialogue 1
			Text = "Greetings little seedling... What do you wish to inquire about?",
			Replies = {
				{ Text = "Knowledge", Next = 4 },
				{ Text = "Purification", Next = 10 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "Can't make up your mind? That's alright. I'll be here if you have anything to ask.",
			Next = nil
		},

		{
			-- dialogue 3: end dialogue
			Text = "May we meet again.",
			Next = nil
		},

		{
			-- dialogue 4: KNOWLEDGE
			Text = "What kind of knowledge do you desire?",
			Replies = {
				{ Text = "Magic.", Next = 5 },
				{ Text = "Gods.", Next = 6 },
				{ Text = "Goal.", Next = 8 }, 
			}

		},
		-- dialogue 5: MAGIC
		{
			Text = "We've had this talk already, haven't we?",
			Replies = {
				{ Text = "...", Next = 2}
			}
		},

		{
			-- dialogue 6: GODS
			Text = "The Gods of this land... The ones that stand above all... You see, unlike what you might think, no one is born a God. The Gods themselves are simply chosen by their previous counterparts.",
			Replies = {
				{ Text = "God.", Next = 9 },
				{ Text = "...", Next = 2 }
			}

		},

		{
			-- dialogue 7: Goddess
			Text = "I'm sorry, but even I have not lived long enough to learn much about her, although I can feel the balance of the universe slowly collapsing from her doings.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 8: GOAL
			Text = "The Goddess is breaking the balance... That's why Aretim sent you, is it not? Perhaps not just to slay her, but also... Ha ha... I hope you succeed. It would be something very interesting to watch.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 9: GOD
			Text = "What? do you intend to become a god yourself? ha ha... that would be interesting, wouldn't it?",
			Replies = {
				{ Text = "Goddess.", Next = 7 },
				{ Text = "...", Next = 2 }
			}

		},
		{
			-- dialogue 10: PURIFICATION
			Text = "I see... Youre like me, a plant life form... but there is something corrupting you, other for the Soul controlling your body, that is. but thats the one im talking to, isnt it?",
			Replies = {
				{ Text = "Removal.", Next = 11 },
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 11: PURIFICATION
			Text = "I can remove it from you permanently, it will change you a little though. Do you want to proceed?",
			Replies = {
				{ Text = "Yes.", Next = 14 },
				{ Text = "No.", Next = 12 }
			}

		},
		{
			-- dialogue 12: ACCEPTANCE
			Text = "If you change your mind, come back to me.",
			Next = nil,

		},
		{
			-- dialogue 13: PURIFICATION
			Text = "I dont advise on it, but i suppose if youre so hesitant... perhaps you could also accept this path, be advised, however, that i wont help you with that.",
			Replies = {
				{ Text = "...", Next = 13 },
			}

		},
		{
			-- dialogue 14: PROCEED
			Text = "Very well.",
			Next = nil

		},
	},
	
	-- for all the maxed freshies of the world
	["MotherTreeTrained"] = {
		{
			-- dialogue 1
			Text = "Greetings little seedling... What do you wish to inquire about?",
			Replies = {
				{ Text = "Knowledge", Next = 4 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "Can't make up your mind? That's alright. I'll be here if you have anything to ask.",
			Next = nil
		},

		{
			-- dialogue 3: end dialogue
			Text = "May we meet again.",
			Next = nil
		},

		{
			-- dialogue 4: KNOWLEDGE
			Text = "What kind of knowledge do you desire?",
			Replies = {
				{ Text = "Magic.", Next = 5 },
				{ Text = "Gods.", Next = 6 },
				{ Text = "Goal.", Next = 8 }, 
			}

		},
		-- dialogue 5: MAGIC
		{
			Text = "We've had this talk already, haven't we?",
			Replies = {
				{ Text = "...", Next = 2}
			}
		},

		{
			-- dialogue 6: GODS
			Text = "The Gods of this land... The ones that stand above all... You see, unlike what you might think, no one is born a God. The Gods themselves are simply chosen by their previous counterparts.",
			Replies = {
				{ Text = "God.", Next = 9 },
				{ Text = "...", Next = 2 }
			}

		},

		{
			-- dialogue 7: Goddess
			Text = "I'm sorry, but even I have not lived long enough to learn much about her, although I can feel the balance of the universe slowly collapsing from her doings.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 8: GOAL
			Text = "The Goddess is breaking the balance... That's why Aretim sent you, is it not? Perhaps not just to slay her, but also... Ha ha... I hope you succeed. It would be something very interesting to watch.",
			Replies = {
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 9: GOD
			Text = "What? do you intend to become a god yourself? ha ha... that would be interesting, wouldn't it?",
			Replies = {
				{ Text = "Goddess.", Next = 7 },
				{ Text = "...", Next = 2 }
			}

		},
	},

		
	-- for all the little magic people of the world
	["MotherTreeTraining"] = {
		{
			Text = "I see you've showed the spirit your might. Bring me 10 souls, and by releasing them, you shall be blessed.",
			Replies = {
				{ Text = "Train.", Next = 2 },
				{ Text = "...", Next = 3 },
			}
		},
		{
			Text = "Goodbye.",
			Next = nil
		},
		{
			Text = "I'll be waiting for you.",
			Next = nil
		},
	},
	-- for all the mekolkals learning from btd6 but not purified i guess
	["MotherTreeMekolkalTraining"] = {
		{
			Text = "I see you've showed the spirit your might. Bring me 10 souls, and by releasing them, you shall be blessed.",
			Replies = {
				{ Text = "Train.", Next = 2 },
				{ Text = "Purification.", Next = 4 },
				{ Text = "...", Next = 3 },
			}
		},
		{
			Text = "Goodbye.",
			Next = nil
		},
		{
			Text = "I'll be waiting for you.",
			Next = nil
		},
		{
			-- dialogue 4: PURIFICATION
			Text = "I see... Youre like me, a plant life form... but there is something corrupting you, other for the Soul controlling your body, that is. but thats the one im talking to, isnt it?",
			Replies = {
				{ Text = "Removal.", Next = 5 },
				{ Text = "...", Next = 3 }
			}

		},
		{
			-- dialogue 5: PURIFICATION
			Text = "I can remove it from you permanently, it will change you a little though. Do you want to proceed?",
			Replies = {
				{ Text = "Yes.", Next = 6 },
				{ Text = "No.", Next = 4 }
			}

		},
		{
			-- dialogue 6: do it
			Text = "Very Well.",
			Next = nil

		},
	},
	
	-- for all the little evil seedlings of the world
	["MotherTreeCorrupted"] = {
		{
			-- dialogue 1
			Text = "I see you have decided on another path. Was it worth it?",
			Replies = {
				{ Text = "Purification", Next = 3 },
				{ Text = "...", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "I see... Hesitant to answer... I hope you find your way. Goodbye.",
			Next = nil
		},

		{
			-- dialogue 3: end dialogue
			Text = "I am unable to fix your mistake. If you are to get a new vessel, perhaps you may pick another path.",
			Next = nil
		},
	},


	
	["Keo"] = {
		{
			Text = "I'm always the one taking the hits for the team... I've seen this hospital more than my family at this point.",
			Replies = {
				{ Text = "Train me.", Next = 3 },
				{ Text = "It gets better.", Next = 2 },
			},
		},
		{
			Text = "Maybe you're right... I should try to stay hopeful...",
			Next = nil,
		},
		{
			Text = "Oh so you want to protect people? A shield is the best weapon for that, come back to me once you have one, I think this town's blacksmith is selling one.",
			Replies = {
				{ Text = "...", Next = 4 }
			}
		},
		{
			Text = "See you around.",
			Next = nil,
		},
	},
	
	["Keo_ShieldEquipped"] = {
		{
			Text = "I see you've got yourself a sturdy shield, you don't seem like you know how to use it though, if you want to I could teach you...",
			Replies = {
				{ Text = "Sure!", Next = 3 },
				{ Text = "I'll think about it", Next = 2 },
			},
		},
		{
			Text = "See you around.",
			Next = nil,
		},
		{
			Text = "Wonderful, though I do need money to be able to afford my hospital bills, I'll teach you for 40 Embers.",
			Replies = {
				{ Text = "Learn.", Next = 4 },
				{ Text = "Maybe later.", Next = 2 }
			},
		},
		{
			Text = "...",
			Next = nil,
		},
	},
	
	["KeoLearning"] = {
		{
			Text = "Didn't get yourself killed yet I see, I'll teach you more for 40 Embers.",
			Replies = {
				{ Text = "Sure.", Next = 3 },
				{ Text = "Maybe later.", Next = 2 }
			},
		},
		{
			Text = "See you around.",
			Next = nil,
		},
		{
			Text = "...",
			Next = nil,
		},
	},
	
	["Keo_Other"] = {
		{
			Text = "I'm always the one taking the hits for the team... I've seen this hospital more than my family at this point.",
			Replies = { Text = "Good luck.", Next = 2 },
		},
		{
			Text = "See you around.",
			Next = nil
		},
	},
	
	["Teks"] = {
		{
			Text = "what are you lookin' at? never seen a seadog on land before?",
			Replies = {
				{ Text = "Goodbye.", Next = 2 },
			}
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["Teks_Permit"] = {
		{
			Text = "what are you lookin' at? never seen a seadog on land before?",
			Replies = {
				{ Text = "Teach me the gun", Next = 2 },
				{ Text = "Goodbye.", Next = 3 },
			}
		},
		{
			Text = "Now that's interesting.. I can teach you a thing or two if you do this poor ol' man a favour.. how about 100 Ember Shards, eh?",
			Replies = {
				{ Text = "pay up", Next = 4 },
				{ Text = "no, thanks", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "Thats the spirit! Now, load it up and shoot something! You gotta smell the gunpowder fiiirst",
			Next = nil
		}
	},
	
	["Teks_QuestCompleted"] = {
		{
			Text =  "HAHA! Can't believe it! You gone right through with it! Fine! I'll teach you some tricks I got in my sleeves.. for a price of 70 Embers of course.",
			Replies = {
				{ Text = "pay up", Next = 2 },
				{ Text = "I'll pass", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["Teks_Training"] = {
		{
			Text = "You wanna lean more? Pay me up 70 ember shards then we talk!" ,
			Replies = {
				{ Text = "pay up", Next = 2 },
				{ Text = "I'll pass", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["Teks_Trained"] = {
		{
			Text = "Haha! Ain't it my favourite buccaneer?!",
			Replies = {
				{ Text = "teach me more!!", Next = 2 },
				{ Text = "no, bye", Next = 3 }
			}
		},
		{
			Text = "Sorry kid, this seadog is outta tricks.. you better off find someone way better than me! Probably far from here.",
			Next = nil
		},
		{
			Text = "See ya!",
			Next = nil
		}
	},


	["Daria"] = {
		{
			Text = "Are you a new vessel? Do you need any guidance?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "I could help you choose your path if you haven't decided already.",
			Replies = {
				{ Text = "Path of the Sword", Next = 4 },
				{ Text = "Path of the Spear", Next = 5 },
				{ Text = "Path of the Martial Arts", Next = 6 },
				{ Text = "...", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "That blind man sun-bathing over there used to be a warrior. Perhaps he could help you.",
			Replies = {
				{ Text = "...", Next = 3 }
			}
		},
		{
			Text = "I believe there's a hunter on top of one of these mountains that's skilled in spearsmanship. She does look a bit sketchy though.",
			Replies = {
				{ Text = "...", Next = 3 }
			}
		},
		{
			Text = "I heard about a skilled Ichthus Martial Artist who traveled all the way to the volcano to train. You could try asking her for help.",
			Replies = {
				{ Text = "...", Next = 3 }
			}
		},
	},


	["Ben"] = {
		{
			Text = "Welcome to my store!",
			Replies = {
				{ Text = "Sell items", Next = 2 },
				{ Text = "Orb", Next = 4},
				{ Text = "Goodbye.", Next = 3 },
			}
		},
		{
			-- open selling items gui
			Text = "What would you like to sell?",
			Next = nil
		},
		
		{
			-- nothing
			Text = "...",
			Next = nil
		},
		{
			-- THE ORB
			Text = "Oh, that thing? I mainly use it for light, and I find it adds a certain charm to my store. It feels almost magical and since we don’t see much magic around here, I think it’s quite neat. If you have a practical use for it, please feel free to help yourself.",
			Replies = {
				{ Text = "Okay", Next = 3 },
			}
		}
	},

	["Rin"] = {
		{
			Text = "Would you like to begin an attempt at our challenges?",
			Replies = {
				{ Text = "Yes.", Next = 3 },
				{ Text = "No.", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "Come back when you do.",
			Next = nil
		},
		{
			-- dialogue 3: end dialogue
			Text = "Very well, assemble your party and let's begin.",
			Replies = {
				{ Text = "Begin.", Next = 4 }
			}
		},
		{
			-- dialogue 4: begin
			Text = "Goodluck.",
			Next = nil
		},
	},
	
	["LabExitDoor"] = {
		{
			Text = "Would you like to leave?",
			Replies = {
				{ Text = "Yes.", Next = 3 },
				{ Text = "No.", Next = 2 }
			}
		},
		{
			-- dialogue 2: end dialogue
			Text = "...",
			Next = nil
		},
		{
			-- dialogue 3: end dialogue
			Text = "...",
			Next = nil
		},

	},


	["Duster"] = {
		{
			Text = "Hey, I'm the owner of the arena, I like organizing party fights, what do you want to do?",
			Replies = {
				{ Text = "Fight you.", Next = 2 },
				{ Text = "Fight another party.", Next = 3 },
				{ Text = "I don't know.", Next = 4 },
			}
		},
		{
			Text = "Ok.",
			Next = nil
		},
		{
			Text = "Ok.",
			Next = nil
		},
		{
			Text = "Come back when you do.",
			Next = nil
		}
	},
	
	["Anneliese"] = {
		{
			Text = "Hey, ain't ya a new face.. Whatcha want?",
			Replies = {
				{ Text = "What's with the door?", Next = 2 },
				{ Text = "Can I come in?", Next = 3 },
				{ Text = "Nothing.", Next = 6 }
			}
		},
		{
			Text = "This door, eh? Yeah, it's the safest way down to the Cavern City! If ya can ignore getting shoved around because of how tight it is.. I'm just guarding it, yeah.",
			Replies = {
				{ Text = "Can I come in?", Next = 3 },
				{ Text = "Ok", Next = 6 }
			}
		},
		{
			Text = "Hell? Soul, letting you in? Don't make me laugh! Such luxury is only allowed for those who aren't shrimps like ya. Go find your own way... unless ya can impress me in a fight.",
			Replies = {
				{ Text = "I will beat you up.", Next = 4 },
				{ Text = "Nevermind", Next = 7 }
			}
		},
		{
			Text = "Oh? Now that's some courage... Ya really sure though? Because this bird ain't gonna go easy on ya.",
			Replies = {
				{ Text = "Let's fight.", Next = 5 },
				{ Text = "Maybe later...", Next = 7 }
			}
		},
		{
			Text = "Going straight for it, huh? Let's dance.",
			Next = nil
		},
		{
			Text = "whatever",
			Next = nil
		},
		{
			Text = "That's what I thought.",
			Next = nil
		}
	},
	
	["AnnelieseBeat"] = {
		{
			Text = "Hell.. soul.. You did horrible and that's good enough for me, great job.",
			Replies = {
				{ Text = "Can I come in?", Next = 2 },
				{ Text = "Goodbye.", Next = 4 }
			}
		},
		{
			Text = "Yeah, go get some good stuffs in there. Better make it worth my wasted fuel~",
			Next = nil
		},
		{
			Text = "See ya.",
			Next = nil
		}
	},
	
	["Dummy"] = {
		{
			Text = "Train?",
			Replies = {
				{ Text = "Fight.", Next = 2 },
				{ Text = "No.", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["DummyGab"] = {
		{
			Text = "Start a battle?",
			Replies = {
				{ Text = "Fight.", Next = 2 },
				{ Text = "...", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["Orb"] = {
		{
			Text = "The Orb. Touch it?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["BeachOrb"] = {
		{
			Text = "An Orb. Seems important.",
			Replies = {
				{ Text = "Touch it.", Next = 2 },
				{ Text = "...", Next = 3 }
			}
		},
		{
			Text = "You have unlocked the Beach location on the orb.",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["LuneOrb"] = {
		{
			Text = "An Orb. Seems important.",
			Replies = {
				{ Text = "Touch it.", Next = 2 },
				{ Text = "...", Next = 3 }
			}
		},
		{
			Text = "You have unlocked the Lune Ville location on the orb.",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["VolcanoOrb"] = {
		{
			Text = "An Orb. Seems important.",
			Replies = {
				{ Text = "Touch it.", Next = 2 },
				{ Text = "...", Next = 3 }
			}
		},
		{
			Text = "You have unlocked the Volcano location on the orb.",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["IslandOrb"] = {
		{
			Text = "An Orb. Seems important.",
			Replies = {
				{ Text = "Touch it.", Next = 2 },
				{ Text = "...", Next = 3 }
			}
		},
		{
			Text = "You have unlocked the Fresco Island location on the orb.",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	


	["HugoDoor"] = {
		{
			Text = "A door. Open it?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 }
			}
		},
		{
			Text = "You don't have the key.",
			Replies = {
				{ Text = "...", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	["ElesigDoor"] = {
		{
			Text = "A door. Open it?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
			
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	["ElesigExitDoor"] = {
		{
			Text = "A door. Open it?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil

		},
		{
			Text = "...",
			Next = nil
		},
	},
-- GATE KIP :fire: :fire: :fire:
	["KipDoor"] = {
		{
			Text = "It's a door. Knock on it?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 5 }
			}
		},
		{
			Text = "Hey punk, You want to come in? You're gonna need to tell me the password.",
			Replies = {
				{ Text = "Tell.", Next = 4 },
				{ Text = "...", Next = 3 }
			}

		},
		{
			Text = "Come back when you actually have the password.",
			Next = nil
		},
		{
			Text = "You don't actually know the password, do you?",
			Replies = {
				{ Text = "Not yet.", Next = 3 },
				{ Text = "...", Next = 3 }
			}

		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	-- gatekeepers supposed to open gates
	["KipDoorPassword"] = {
		{
			Text = "It's a door. Knock on it?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 5 }
			}
		},
		{
			Text = "Hey punk, You want to come in? You're gonna need to tell me the password.",
			Replies = {
				{ Text = "Tell.", Next = 4 },
				{ Text = "Dont tell.", Next = 3 }
			}

		},
		{
			Text = "If you dont want to come in, why did you knock!? ",
			Next = nil
		},
		{
			Text = "Alright, welcome in.",
			Next = nil
		},
		{
			Text = "...",
			Next = nil

		},
	},

	-- gatekeepers supposed to open gates
	["Clein"] = {
		{
			Text = "Hey punk. I'm selling the password to get in through that door, wanna buy?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 4 }
			}
		},
		{
			Text = "Alright! The password is: imnotbroke! It woudn't work if you were, infact, broke.",
			Next = nil
		},
		{
			Text = "Heh, later brokie!",
			Next = nil

		},
	},
	
	-- gatekeepers supposed to open gates
	["Kip"] = {
		{
			Text = "Hey punk. Wanna leave?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 4 }
			}
		},
		{
			Text = "Alright.",
			Next = nil
		},
		{
			Text = "...",
			Next = nil

		},
	},
	
	-- gatekeepers supposed to open gates, but you already opened it.
	["CleinQuestDone"] = {
		{
			Text = "By the way, telling someone else the password doesn't work unless they pay me, i tell Kip when someone buys the password, its more of a list than a password, really.",
			Replies = {
				{ Text = "Wow.", Next = 2 },
			}
		},
		{
			Text = "Heh.",
			Replies = {
				{ Text = "Bye.", Next = 3 },
			}
		},
		{
			Text = "later brokie!",
			Next = nil

		},
	},


	["Mendi"] = {
		{
			Text = "Hello. Do you need any medical treatment?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			Text = "I'll heal you right away.",
			Next = nil
		},
		{
			Text = "Don't get into too much trouble!",
			Next = nil
		},
	},
	
	-- Soul Giver
	-- evil gabe agres
	["Agres"] = {
		{
			Text = "Say, little vessel, do you seek to make your body stronger? If you collect souls for Aretim and bring them to me, I can strengthen your physical body.",
			Replies = {
				{ Text = "Give Souls.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			-- open the souls gui
			Text = "...",
			Next = nil
		},
		{
			Text = "Until next time.",
			Next = nil
		},
	},
	-- who made this 
	["Agres_Fight"] = {
		{
			Text = "You've been loyal I see, Aretim wants me to reward you, I'll let you choose one if you beat me in a fight.",
			Replies = {
				{ Text = "Fight.", Next = 4 },
				{ Text = "Give Souls.", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "Until next time.",
			Next = nil
		},
		{
			Text = "Very well, gather your party and let's begin, unless you'd like to try doing it alone of course. I'll try to go easy on you regardless...",
			Replies = {
				{ Text = "Ready.", Next = 5 }
			}
		},
		{
			Text = "Good luck.",
			Next = nil
		}
	},
	-- who made this yo
	["Agres_Reward"] = {
		{
			Text = "Congratulations, let's call it your victory, what item would you like?",
			Replies = {
				{ Text = "Orb of Genesis", Next = 3 },
				{ Text = "I'll think about it", Next = 2 },
			}
		},
		{
			Text = "Until next time.",
			Next = nil
		},
		{
			Text = "Very well.",
			Next = nil
		}
	},
	
	["Agres_Quest"] = {
		{
			Text = "placeholder, collect my artifacts or something i battle you.",
			Replies = {
				{ Text = "give [ARTIFACT]", Next = 3 },
				{ Text = "I'll think about it", Next = 2 },
			}
		},
		{
			Text = "Until next time.",
			Next = nil
		},
		{
			Text = "Very well.",
			Next = nil
		}
	},
	
	-- not to be confused with ember shards
	["Ember"] = {
		{
			Text = "Oh, hello there, stranger.",
			Replies = {
				{ Text = "The Volcano", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			Text = "My grandparents used to tell me stories about the Fire God. They tole me that this volcano's might is directly linked to his strength, but recently it has been weakening... I wonder what that could mean?",
			Replies = {
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			Text = "Goodbye, stranger.",
			Next = nil
		},
	},
	
	--SEA n - pronounced shaw! SilkSong
	["Sean"] = {
		{
			Text = "Want a ride to Fresco Island?",
			Replies = {
				{ Text = "How much?", Next = 2 },
				{ Text = "Lets go!", Next = 4},
				{ Text = "Goodbye.", Next = 3 }
			},
		},
		{
			-- No fees, he's generous
			Text = "Oh, don't worry about the price! I'm paid by the shopkeepers on the island. After all, they can't sell anything if no one can reach them!",
			Replies = {
				
				{ Text = "Lets go!", Next = 4 },
				{ Text = "maybe next time.", Next = 3 },
			}
		},
		{
			Text = "See ya!",
			Next = nil
		},
		-- dialogue 4, boat trip to the island
		{
			Text = "Alright.",
			Next = nil
		}
	},
	
	--SEA n - pronounced shaw! SilkSong
	["SeanIsland"] = {
		{
			Text = "Wanna head back?",
			Replies = {
				{ Text = "Lets go!", Next = 3},
				{ Text = "Goodbye.", Next = 2 }
			},
		},
		{
			Text = "See ya!",
			Next = nil
		},
		-- Boat trip to the beach
		{
			Text = "Alright.",
			Next = nil
		}
	},
	
	-- neythan
	["Nate"] = {
		{
			Text = "Oh... I forgot my Ember Shards at home...",
			Replies = {
				{ Text = "I could help.", Next = 2 },
				{ Text = "...", Next = 3 },
			}
		},
		{
			Text = "Really? If you get some shards from my sister in Luneville for me, I'll let you keep some.",
			Replies = {
				{ Text = "Accept", Next = 4 }, 
				{ Text = "Decline", Next = 3 },
			}
		},

		{
			Text = "...",
			Next = nil
		},

		{
			Text = "Her name is Kate; tell her to get the shards from under my bed.",
			Replies = {
				{ Text = "Okay.", Next = 5 },
			}
		},
		-- accept quest
		{
			Text = "...",
			Next = nil
		}
	},

	["Kate"] = {
		{
			Text = "I'm glad we don't need torches to go to the caves anymore... I always used to lose mine...",
			Replies = {
				{ Text = "Goodbye.", Next = 2 },
			}
		},
		{
			Text = "Goodbye.",
			Next = nil
		},
	},

	["KateQuest"] = {
		{
			Text = "Hello.",
			Replies = {
				{ Text = "Nate sent me.", Next = 2 },
				{ Text = "...", Next = 3 },
			}
		},
		{
			Text = "Did he forget to bring shards for his drinks again?",
			Replies = {
				{ Text = "Yeah.", Next = 4 }, 
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "Here, his drink shards are in this box; take them to him.",
			Replies = {
				{ Text = "Okay.", Next = 5 },
			}
		},
		{
			Text = "...",
			Next = nil
		}
	},

	["NateQuest"] = {
		{
			Text = "Tell me when you get the shards.",
			Replies = {
				{ Text = "Okay.", Next = 2 },
			}
		},
		{
			Text = "...",
			Next = nil
		}
	},

	["NateUndoneQuest"] = {
		{
	
			Text = "Oh! Thank you. Here, have 60 Ember Shards.",
			Replies = {
				{ Text = "Claim.", Next = 2 },
			}
		},
		{
			Text = "...",
			Next = nil
		}
	},

	["NateHasShards"] = {
		{
			
			Text = "Thank you!",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	
	["Rex"] = {
		{
			Text = "What's up? Wanna buy anything?",
			Replies = {
				{ Text = "Buy.", Next = 2 },
				{ Text = "Sell.", Next = 4 },
				{ Text = "Quest.", Next = 5 }
			}
		},
		{
			-- shop maybe potions or smt idk (better than crafting with enchanted flowers in pb)
			Text = "Let me show ya what I've got.",
			Next = nil
		},
		{
			
			Text = "Come back if you need anything!",
			Next = nil
		},
		{
			Text = "Sorry bud, but I'm the one selling here.",
			Replies = {
				{ Text = "...", Next = 3 },
			}
		},
		{
			Text = "Hmm... I'd pay you if you could bring me some ingredients from my friend at LuneVille. He was supposed to bring them today, but he never showed up. His name is Denis; I'll pay you well if you can do it.",
			Replies = {
				{ Text = "I can do that.", Next = 6 },
				{ Text = "Let me think.", Next = 7 },
			}
		},
		{
			-- Accept Quest
			Text = "Alright, I'll be waiting.",
			Next = nil
		},
		{
			-- Decline Quest
			Text = "Suit yourself. I'll be here if you change your mind.",
			Next = nil
		}
	},
	
	["RexQuest"] = {
		{
			Text = "What's up?",
			Replies = {
				{ Text = "Buy.", Next = 2 },
				{ Text = "Quest.", Next = 4 },
			}
		},
		{
			Text = "Alright.",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "Did you forget already? His name is Denis; he's probably still in LuneVille.",
			Replies = {
				{ Text = "...", Next = 3 },
			}
		},
	},
	
	
	["RexQuestDone"] = {
		{
			Text = "What's up?",
			Replies = {
				{ Text = "Buy.", Next = 2 },
				{ Text = "...", Next = 3 },
			}
		},
		{
			Text = "Alright.",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		},
	},

	
	["RexIngredients"] = {
		{
			Text = "So? Got the ingredients?",
			Replies = {
				{ Text = "Yes.", Next = 4 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "See ya.",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "Thanks. Denis must've forgotten he had to deliver them and got caught up in something else; he's been very forgetful ever since he got lost in the jungle... Anyways, here's your pay. Don't spend it all in one place, Unless it's my shop!",
			Next = nil
		},
	},
	
	
	["Denis"] = {
		{
			Text = "Ugh... I lost my keys again...",
			Replies = {
				{ Text = "...", Next = 2 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
	},


	["DenisQuest"] = {
		{
			Text = "Ugh... I lost my keys again...",
			Replies = {
				{ Text = "Rex.", Next = 2 },
				{ Text = "...", Next = 3 },
			}
		},
		{
			Text = "Oh no... I forgot I had to go deliver him the ingredients... I keep forgetting things; I just lost my house keys too...",
			Replies = {
				{ Text = "I can do it.", Next = 4 },
				{ Text = "Goodluck", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "Oh, that would be nice... Then I can go back to looking for my keys... Here. Take the ingredients to him.",
			Replies = {
				{ Text = "...", Next = 5 },
			}
		},
		{
			Text = "...",
		    Next = nil
		},
	},
	
	

	["Elesig"] = {
		{
			Text = "Hey buddy!",
			Replies = {
				{ Text = "Who are you?", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "Im known to you people as Elesig. I am a Demi-God",
			Replies = {
				{ Text = "Really?", Next = 4 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "Goodbye.",
			Next = nil
		},
		{
			Text = "Yes. I used to be the God of Air, but that was too limiting, having a specific purpose and all. I threw away all my responsabilities, nothing holds me back any longer.",
			Replies = {
				{ Text = "...", Next = 5 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "Say, some mortal beings attempted to kill me, I still have their souls, if you have any use for souls I can give them to you.",
			Replies = {
				{ Text = "Accept.", Next = 6 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "You received 10 souls.",
			Next = nil
		},
	},
	
	["Elesig2"] = {
		{
			Text = "Hey buddy!",
			Replies = {
				{ Text = "...", Next = 2 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "Got nothing to say? And yet you still came back... Freedom is a beautiful thing, huh?",
			Replies = {
				{ Text = "Freedom", Next = 4 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "Goodbye.",
			Next = nil
		},
		{
			Text = "Ah, I understand, you must think you aren't free... But listen to me, the gods dont decide your fate. If anything, you decide theirs. You have a choice, unlike what others may tell you, pick a side, or make your own.",
			Replies = {
				{ Text = "...", Next = 5 }
			}
		},
		{
			Text = "You couldve simply walked away, you already made a choice, dont let others pick your path for you.",
			Next = nil
		},
	},
	
	["ElesigCombat"] = {
		{
			Text = "Hey buddy! I see your soul disconected from your body, and you got sent here. Got any questions before I send you back to Aretim?",
			Replies = {
				{ Text = "Who are you?", Next = 2 },
				{ Text = "Revive.", Next = 4 },
				{ Text = "Gods.", Next = 6 },
				{ Text = "No thanks.", Next = 3 }
			}
		},
		{
			Text = "I am the Demi-God Elesig. The god of Freedom.",
			Replies = {
				{ Text = "Revive.", Next = 4 },
				{ Text = "Gods.", Next = 6 },
				{ Text = "Send me back.", Next = 3 }
			}
		},
		{
			Text = "Alright.",
			Next = nil
		},
		{
			Text = "Did your vessel run out of power? I'm sure someone skilled enough might be able to bring you back somehow, but it might not be worth it to wait until that happens.",
			Replies = {
				{ Text = "How?", Next = 5 },
				{ Text = "Goodbye.", Next = 3 }
			}
		},
		{
			Text = "I've heard of some rituals made by necromancers to bring back the dead through the use of a death gate, I'm sure Aretim doesn't mind, but the goddess might send someone to stop you from escaping the purgatory.",
			Replies = {
				{ Text = "Gods.", Next = 6 },
				{ Text = "Send me back.", Next = 3 }
			}
		},
		{
		Text = "Demi-Gods such as me aren't that diferent from pure Gods, we all represent something, but Demi-Gods throw away part of themselves to achieve some other goal. I simply wanted freedom.",
		Replies = {
			{ Text = "Pure Gods.", Next = 7},
			{ Text = "Send me back.", Next = 3 }
		}
		},
		{
			Text = "But pure Gods like Aretim grow stronger the more purpose they have, the Goddess is trying to grow stronger by making her own role bigger. Basically becoming stronger by being God, instead of being God because of her strength.",
			Replies = {
				{ Text = "Send me back.", Next = 3 }
			}
		},
	},
	 
		
			

	["ClunkyArmor"] = {
		{
			Text = "Do you want to buy the Clunky Armor for 75 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},

	["ClunkyHelmet"] = {
		{
			Text = "Do you want to buy the Clunky Helmet for 50 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["SunHelmet"] = {
		{
			Text = "Do you want to buy the Sun Helmet for 100 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["SpartanHelmet"] = {
		{
			Text = "Do you want to buy the Spartan Helmet for 90 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["TravelerHood"] = {
		{
			Text = "Do you want to buy the Traveler Hood for 40 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			},
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["VolcanicHelmet"] = {
		{
			Text = "Do you want to buy the Volcanic Helmet for 120 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			},
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["BlueMageArmor"] = {
		{
			Text = "Do you want to buy the Blue Mage Armor for 100 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["WarriorArmor"] = {
		{
			Text = "Do you want to buy the Warrior Armor for 120 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["SpearfighterArmor"] = {
		{
			Text = "Do you want to buy the Spearfighter Armor for 140 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["DefenderArmor"] = {
		{
			Text = "Do you want to buy the Defender Armor for 80 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["VolcanicArmor"] = {
		{
			Text = "Do you want to buy the Volcanic Armor for 150 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3},
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["GothicSpec"] = {
		{
			Text = "ARE YOU GOTHIC?!",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["TackySuit"] = {
		{
			Text = "Do you want to buy the Tacky Suit for 120 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["LeafCrown"] = {
		{
			Text = "Do you want to buy the Leaf Crown for 30 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		}
	},
	
	["BasicSpear"] = {
		{
			Text = "Do you want to buy the Basic Spear for 75 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	["BasicSword"] = {
		{
			Text = "Buy basic sword for 20 ember shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	["BasicShield"] = {
		{
			Text = "Do you want to buy the Basic Shield for 50 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	["BasicFlintlock"] = {
		{
			Text = "Do you want to buy the Basic Flintlock for 50 Ember Shards?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "No.", Next = 3 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	
	["Grim"] = {
		{
			Text = "Hey there, are you interested in buying some relics?",
			Replies = {
				{ Text = "Yes.", Next = 2 },
				{ Text = "What are they for?", Next = 4 },
				{ Text = "Maybe later.", Next = 3 },
			}
		},
		{
			Text = "Here is what I have in stock.",
			Next = nil 
		},
		{
			Text = "...",
			Next = nil
		},
		{
			Text = "Wait a second. I can see it now. You aren't just a regular visitor, are you? I usually tell people these are just trinkets to give to friends, but you're definitely different.",
			Replies = {
				{ Text = "Different?", Next = 5 },
				{ Text = "Relics.", Next = 8 }, 
			},
		},
		{
			Text = "Yes, you are one of Aretim's vessels. I would bet he didn't bother to explain how any of this works to you.",
			Replies = {
				{ Text = "Aretim.", Next = 6 }, 
				{ Text = "Relics.", Next = 8 }, 
			},
		},
		{
			Text = "Aretim didn't actually create you. The God of Death cannot create life the same way the Goddess does. He just learned the forbidden secrets of how your kind works. He is essentially taking the souls she creates and using them for his own goals.",
			Replies = {
				{ Text = "The Goddess.", Next = 7 }, 
				{ Text = "Relics.", Next = 8 }, 
			},
		},
		{
			Text = "You might consider switching sides, but that isn't really your choice to make. Besides, the current Goddess of Birth is far too prideful to ever accept you anyway.",
			Replies = {
				{ Text = "Relics.", Next = 8 }, 
			},
		},
		{
			Text = "Relics are very useful for vessels like you. They can increase your power through a simple boost or a trade to get something else. We use ancient technology to create them and sell them to travelers.",
			Replies = {
				{ Text = "Technology", Next = 9 }, 
			},
		},
		{
			Text = "I'll let you in on a secret. The temple on the back of this jungle isnt really abandoned. We could use someone like you to experiment, there will be some rewards in for you of course.",
			Replies = {
				{ Text = "buy.", Next = 2 }, 
				{ Text = "...", Next = 3 }, 
			},
		},
	},
	
	["SwordPedestal"] = {
		{
			Text = "It's an old sword pedestal, does not seem wieldable.",
			Replies = {
				{ Text = "...", Next = 2 },
			}
		},
		{
			Text = "...",
			Next = nil
		},
	},
	
	-- finish cutscene in the gui and stuff later 
	-- make logic for this if possible barbarian candidate
	-- maybe make you need max health
	["BarbarianSwordPedestal"] = {
		{
			Text = "It's an old sword pedestal, does not seem wieldable.",
			Replies = {
				{ Text = "Interact.", Next = 3 },
				{ Text = "...", Next = 2 },
			}
		},
		{
			Text = "...",
			Next = nil 
		},
		{
			Text = "You touch the sword, your vision starts to fade...",
			Next = nil
		},
	},

    ["RitualCircle"] = {
		{
			Text = "There is something drawn on the floor, touch it?",
			Replies = {
				{ Text = "Yes.", Next = 2 }, 
				{ Text = "No.", Next = 3 }, 
			}
		},
		{
			Text = "You feel it ask for a few things, keop what does this thing need for power again",
			Replies = {
				{ Text = "Give items.", Next = 4 }, 
				{ Text = "Ignore.", Next = 3 }, 
			}
		},
		{
			Text = "...",
			Next = nil
		},
        {
			Text = "It begins to glow...",
			Next = nil
		},
	},
	
	["Selden"] = {
		{
			Text = "These damned crystals...",
			Replies = {
				{ Text = "Buy Torch.", Next = 2 }, 
				{ Text = "Bye!", Next = 3 }, 
			}
		},
		{
			Text = "A torch? the caverns are lighted up by the crystals nowadays, you won't need one...",
			Next = nil
		},
		{
			Text = "See you around.",
			Next = nil
		},
	},
}

return NPCDialogue