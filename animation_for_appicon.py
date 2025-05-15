from manim import *
import numpy as np
import os

# Konfiguration für quadratisches Ausgabeformat
config.frame_height = 8.0
config.frame_width = 8.0
config.pixel_height = 1080
config.pixel_width = 1080
config.frame_size = (1080, 1080)

class AppIconAnimation(Scene):
    def construct(self):
        # App-Farbe
        app_color = "#9938EB"
        
        # Pfad zum SVG
        svg_path = "/Users/felix/Xcode/Dreams/Dreams/moon.fill.svg"
        
        # Überprüfen, ob das SVG existiert
        if not os.path.exists(svg_path):
            # Fallback: Erstelle einen Platzhalter mit Text "Dreams"
            self.create_placeholder_animation(app_color)
            return
        
        # Schwarzer Hintergrund ist bereits vorhanden
        self.wait(0.5)
        
        # Erstelle ein quadratisches Hintergrund-Rechteck mit abgerundeten Ecken
        rounded_square = RoundedRectangle(
            corner_radius=1,
            height=5,
            width=5,
            fill_opacity=1,
            fill_color=app_color,
            stroke_width=0
        )
        
        # Einblenden des Hintergrunds und vergrößern
        self.play(
            FadeIn(rounded_square, run_time=1.0)
        )
        self.play(
            rounded_square.animate.scale(1.15),
            run_time=0.8,
            rate_func=smooth
        )
        
        # Lade das SVG und extrahiere nur die Mondform
        svg_mobject = SVGMobject(svg_path)
        
        # Entferne alle Hintergrundelemente (normalerweise das erste Element)
        # und behalte nur die Pfade, die den Mond darstellen
        if len(svg_mobject.submobjects) > 1:
            # Wenn es mehrere Submobjects gibt, nehmen wir an, dass das erste der Hintergrund ist
            moon_shape = VGroup(*svg_mobject.submobjects[1:])
        else:
            # Wenn es nur ein Submobject gibt, verwenden wir das
            moon_shape = svg_mobject
        
        # Erstelle den Mond-Umriss mit dünner Linie
        moon_outline_thin = moon_shape.copy()
        moon_outline_thin.scale(2)
        moon_outline_thin.set_fill(opacity=0)
        moon_outline_thin.set_stroke(WHITE, opacity=1, width=2)
        
        # Erstelle den Mond-Umriss mit dicker Linie für die finale Darstellung
        moon_outline_thick = moon_shape.copy()
        moon_outline_thick.scale(2)
        moon_outline_thick.set_fill(opacity=0)
        moon_outline_thick.set_stroke(WHITE, opacity=1, width=35)  # Dickere Linie statt Füllung
        
        # Zentriere die Monde im Rechteck
        moon_outline_thin.move_to(rounded_square.get_center())
        moon_outline_thick.move_to(rounded_square.get_center())
        
        # Animation des Zeichnens der Umrandung mit angepasstem Startpunkt
        self.play(
            DrawBorderThenFill(moon_outline_thin, run_time=1.5, stroke_width=2, 
                              stroke_color=WHITE, fill_opacity=0,
                              draw_border_animation_config={"run_time": 1.5, "rate_func": linear}),
            rate_func=smooth
        )
        
        # Animation zum Verdicken der Umrandung (statt Füllen)
        self.play(
            Transform(moon_outline_thin, moon_outline_thick, run_time=0.6),
            rate_func=smooth
        )
        self.wait(0.5)
        
        # Erstelle eine Gruppe für das Icon
        icon_group = Group(rounded_square, moon_outline_thin)
        
        # Erstelle den Text "Dreams" in Helvetica Bold
        app_name = Text("Dreams", font="Helvetica", weight="BOLD", color=WHITE, font_size=64)
        
        # Positioniere den Text unter dem Icon, aber näher am Icon
        app_name.next_to(icon_group, DOWN, buff=0.3)
        
        # Verschiebe das Icon weiter nach oben, um Platz für den Text zu schaffen
        self.play(
            icon_group.animate.shift(UP * 1),
            run_time=0.8,
            rate_func=smooth
        )
        
        # Einblenden des Textes
        self.play(
            Write(app_name, run_time=1.0),
            rate_func=smooth
        )
        
        self.wait(0.8)
        
        # # Alles zusammen kleiner machen und ausblenden
        # final_group = Group(icon_group, app_name)
        # self.play(
        #     final_group.animate.scale(0.7),
        #     run_time=1.0,
        #     rate_func=smooth
        # )
        # self.play(
        #     FadeOut(final_group, run_time=1.2),
        #     rate_func=smooth
        # )
        self.wait(0.5)
        
    def create_placeholder_animation(self, app_color):
        # Erstelle einen Platzhalter mit Text "Dreams"
        self.wait(0.5)
        
        rounded_square = RoundedRectangle(
            corner_radius=0.5,
            height=5,
            width=5,
            fill_opacity=1,
            fill_color=app_color,
            stroke_width=0
        )
        
        # Einblenden des Hintergrunds und vergrößern
        self.play(
            FadeIn(rounded_square, run_time=1.0)
        )
        self.play(
            rounded_square.animate.scale(1.15),
            run_time=0.8,
            rate_func=smooth
        )
        self.wait(0.3)
        
        # Erstelle Text-Umriss
        title_outline = Text("Dreams", font_size=72)
        title_outline.set_fill(opacity=0)
        title_outline.set_stroke(WHITE, opacity=1, width=2)
        
        # Erstelle gefüllten Text
        title_filled = Text("Dreams", font_size=72, color=WHITE)
        
        # Zentriere den Text
        title_outline.move_to(rounded_square.get_center())
        title_filled.move_to(rounded_square.get_center())
        
        # Animation des Zeichnens der Umrandung mit angepasstem Startpunkt
        self.play(
            DrawBorderThenFill(title_outline, run_time=1.5, stroke_width=2, 
                              stroke_color=WHITE, fill_opacity=0,
                              draw_border_animation_config={"run_time": 1.5, "rate_func": linear}),
            rate_func=smooth
        )
        self.wait(0.2)
        
        # Füllen des Textes
        self.play(
            FadeIn(title_filled, run_time=1.0),
            FadeOut(title_outline, run_time=0.5),
            rate_func=smooth
        )
        self.wait(0.5)
        
        # Erstelle eine Gruppe für das Icon
        icon_group = Group(rounded_square, title_filled)
        
        # Erstelle den Text "Dreams" in Helvetica Bold
        app_name = Text("Dreams", font="Helvetica", weight="BOLD", color=WHITE, font_size=48)
        
        # Positioniere den Text unter dem Icon, aber näher am Icon
        app_name.next_to(icon_group, DOWN, buff=1)
        
        # Verschiebe das Icon weiter nach oben, um Platz für den Text zu schaffen
        self.play(
            icon_group.animate.shift(UP),
            run_time=0.8,
            rate_func=smooth
        )
        
        # Einblenden des Textes
        self.play(
            Write(app_name, run_time=1.6),
            rate_func=smooth
        )
        
        
