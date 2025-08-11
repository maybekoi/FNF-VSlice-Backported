package funkin.data;

import funkin.data.Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import funkin.data.Event;
import funkin.data.Event.EventData;

using StringTools;

typedef VSliceMetadata = {
	var version:String;
	var timeFormat:String;
	var artist:String;
	var charter:String;
	var playData:{
		var stage:String;
		var characters:{
			var player:String;
			var girlfriend:String;
			var opponent:String;
		};
		var ratings:Dynamic;
		var difficulties:Array<String>;
		var noteStyle:String;
		var album:String;
		var stickerPack:String;
		var previewStart:Float;
		var previewEnd:Float;
	};
	var songName:String;
	var timeChanges:Array<{
		var d:Int;
		var n:Int;
		var t:Int;
		var bt:Array<Int>;
		var bpm:Int;
	}>;
	var generatedBy:String;
}

typedef VSliceChart = {
	var version:String;
	var scrollSpeed:Dynamic;
	var events:Array<{
		var t:Float;
		var e:String;
		var v:Dynamic;
	}>;
	var notes:Array<{
		var t:Float;
		var d:Int;
		var s:Int;
		var y:Int;
		var type:String;
	}>;
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;

	@:optional var isVSliceFormat:Bool;
	@:optional var events:Array<EventData>;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var girlfriend:String = 'gf';

	public var metadata:VSliceMetadata;
	public var chart:VSliceChart;
	public var isVSliceFormat:Bool = false;
	public var events:Array<EventData> = [];

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public function fromVSlice(metadata:Dynamic, chart:Dynamic, difficulty:String = "normal"):Void
	{
		this.metadata = metadata;
		this.chart = chart;
		this.isVSliceFormat = true;
		
		if (chart.events != null) {
			this.events = cast chart.events;
			this.events.sort((a, b) -> Std.int(a.t - b.t));
		}

		this.song = metadata.songName;
		this.bpm = metadata.timeChanges[0].bpm;
		
		var difficultyIndex = metadata.playData.difficulties.indexOf(difficulty.toLowerCase());
		if (difficultyIndex == -1) difficultyIndex = 1;
		
		var speeds:Dynamic = chart.scrollSpeed;
		var diffSpeed:Dynamic = Reflect.field(speeds, difficulty.toLowerCase());
		this.speed = (diffSpeed != null) ? cast(diffSpeed, Float) : cast(speeds.normal, Float);
		
		this.player1 = metadata.playData.characters.player;
		this.player2 = metadata.playData.characters.opponent;
		this.girlfriend = metadata.playData.characters.girlfriend;

		this.notes = [];
		var currentSection:SwagSection = null;
		var lastTime:Float = 0;

		var diffNotes:Array<Dynamic> = cast Reflect.field(chart.notes, difficulty.toLowerCase());
		if (diffNotes == null) {
			trace('No notes found for difficulty: ' + difficulty + ', falling back to normal');
			diffNotes = cast Reflect.field(chart.notes, "normal");
		}
		
		trace('Converting ' + diffNotes.length + ' notes for difficulty: ' + difficulty);
		for (note in diffNotes)
		{
			var sectionTime:Float = (60000 / this.bpm) * 4;
			var currentSectionIndex:Int = Math.floor(note.t / sectionTime);

			if (currentSection == null || currentSectionIndex >= this.notes.length)
			{
				currentSection = {
					lengthInSteps: 16,
					bpm: this.bpm,
					changeBPM: false,
					mustHitSection: true,
					sectionNotes: [],
					typeOfSection: 0,
					altAnim: false
				};
				this.notes.push(currentSection);
			}
			var direction:Int = note.d;
			var isOpponentNote:Bool = direction >= 4;
			
			if (isOpponentNote) {
				direction -= 4;
			}
			
			if (!currentSection.mustHitSection) {
				direction += (isOpponentNote ? 0 : 4);
			} else {
				direction += (isOpponentNote ? 4 : 0);
			}
			
			var sustain:Float = note.l != null ? note.l : 0;
			currentSection.sectionNotes.push([note.t, direction, sustain]);
		}
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var basePath = 'assets/data/songs/' + folder.toLowerCase() + '/';
		var songName = folder.toLowerCase();
		var difficulty = "";
		
		if (jsonInput.toLowerCase() != songName)
		{
			difficulty = jsonInput.substr(songName.length + 1);
		}

		try {
			var metadataPath = basePath + songName + '-metadata.json';
			var chartPath = basePath + songName + '-chart.json';

			trace('Trying to load V-Slice format:');
			trace('  Metadata path: ' + metadataPath);
			trace('  Chart path: ' + chartPath);

			var metadataJson = Assets.getText(metadataPath).trim();
			var chartJson = Assets.getText(chartPath).trim();

			trace('Successfully loaded V-Slice files');

			while (!metadataJson.endsWith("}")) metadataJson = metadataJson.substr(0, metadataJson.length - 1);
			while (!chartJson.endsWith("}")) chartJson = chartJson.substr(0, chartJson.length - 1);

			var metadata:Dynamic = Json.parse(metadataJson);
			var chart:Dynamic = Json.parse(chartJson);

			var song = new Song("", [], 0);
			song.fromVSlice(metadata, chart, difficulty);
			return cast song;
		}
		catch (e:Dynamic)
		{
			trace('Failed to load chart: ' + e);
			return null;
		}
	}
}