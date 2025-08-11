package funkin.data;

import funkin.data.Section.SwagSection;
import funkin.play.PlayState;
import funkin.play.Character;
import funkin.util.CoolUtil;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using StringTools;

typedef EventData = {
    var t:Float;
    var e:String;
    var v:Dynamic;
}

class Event {
    static var types:Map<String, (Dynamic, PlayState) -> Void>;

    static function __init__() {
        types = [
            "FocusCamera" => focusCamera,
            "ZoomCamera" => zoomCamera,
            "PlayAnimation" => playAnimation,
            "ScrollSpeed" => scrollSpeed
        ];
    }

    public static function handleEvent(event:EventData, state:PlayState):Void {
        if (types.exists(event.e)) {
            types.get(event.e)(event.v, state);
        } else {
            trace('Unknown event type: ${event.e}');
        }
    }

    static function focusCamera(params:Dynamic, state:PlayState):Void {
        var char:Int = params.char;
        
        @:privateAccess {
            var targetChar:Character = switch(char) {
                case 0: state.dad;
                case 1: state.boyfriend;
                case 2: state.gf;
                default: null;
            };

            if (targetChar != null) {
                var mid = targetChar.getMidpoint();
                if (targetChar == state.gf) {
                    state.camFollow.setPosition(mid.x, mid.y);
                } else {
                    var xAdd:Float = 0;
                    var yAdd:Float = 0;

                    if (targetChar.curCharacter.startsWith('mom'))
                        yAdd = 50;
                    
                    if (targetChar.isPlayer)
                        xAdd = 150;
                    else
                        xAdd = -100;

                    state.camFollow.setPosition(mid.x + xAdd, mid.y - 100 + yAdd);
                }
            }
        }
    }

    static function zoomCamera(params:Dynamic, state:PlayState):Void {
        var zoom:Float = params.zoom;
        var duration:Float = params.duration;
        var ease:String = params.ease;
        
        @:privateAccess {
            if (duration > 0) {
                FlxTween.tween(FlxG.camera, {
                    zoom: zoom
                }, duration / 1000, {
                    ease: CoolUtil.getEaseFromString(ease),
                    onComplete: function(_) {
                        state.defaultCamZoom = zoom;
                    }
                });
            } else {
                FlxG.camera.zoom = zoom;
                state.defaultCamZoom = zoom;
            }
        }
    }

    static function playAnimation(params:Dynamic, state:PlayState):Void {
        var target:String = params.target;
        var anim:String = params.anim;
        var force:Bool = params.force;
        
        @:privateAccess {
            var targetChar:Character = switch(target.toLowerCase()) {
                case "dad": state.dad;
                case "boyfriend", "bf": state.boyfriend;
                case "gf", "girlfriend": state.gf;
                default: null;
            };

            if (targetChar != null) {
                if (force || targetChar.animation.curAnim.name != anim) {
                    targetChar.playAnim(anim, force);
                }
            }
        }
    }

    static function scrollSpeed(params:Dynamic, state:PlayState):Void {
        var scroll:Float = params.scroll;
        var duration:Float = params.duration;
        var ease:String = params.ease;
        var strumline:String = params.strumline;
        var absolute:Bool = params.absolute;
        
        var targetSpeed = absolute ? scroll : PlayState.SONG.speed * scroll;
        
        if (duration > 0) {
            FlxTween.tween(state, {
                songSpeed: targetSpeed
            }, duration, { ease: CoolUtil.getEaseFromString(ease) });
        } else {
            state.songSpeed = targetSpeed;
        }
    }
}