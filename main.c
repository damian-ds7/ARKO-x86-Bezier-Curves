#include <stdio.h>
#include <stdlib.h>
#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_native_dialog.h>
#include "bezier.h"

#define MAX_POINTS 5


const int WIDTH = 1024;
const int HEIGHT = 1024;

typedef struct Points {
	int counter;
	int x[MAX_POINTS];
	int y[MAX_POINTS];
} Points;

void draw_bezier (ALLEGRO_BITMAP *image, ALLEGRO_DISPLAY *display, Points *points);

int main(int argc, char* argv[]) {
	ALLEGRO_DISPLAY *display = NULL;
	ALLEGRO_EVENT_QUEUE *event_queue = NULL;
	ALLEGRO_BITMAP *image = NULL;

	bool draw = true;

	if (!al_init()) {
		printf("Error initializing Allegro\n");
		exit(-1);
	}

	display = al_create_display(WIDTH, HEIGHT);
	if (!display) {
		printf("Error creating display\n");
		exit(-1);
	}
	al_set_window_title(display, "Interactive Bezier Curves");

	event_queue = al_create_event_queue();
	if (!event_queue) {
		printf("Error creating event queue\n");
		exit(-1);
	}

	image = al_create_bitmap(WIDTH, HEIGHT);
	al_install_mouse();
	al_init_image_addon();
	al_set_target_bitmap(image);
	al_clear_to_color(al_map_rgb(255, 255, 255));
	al_set_target_backbuffer(display);

	al_register_event_source(event_queue, al_get_display_event_source(display));
	al_register_event_source(event_queue, al_get_mouse_event_source());

	Points points;
	points.counter = 0;

	while (true) {
		ALLEGRO_EVENT ev;
		al_wait_for_event(event_queue, &ev);

		switch (ev.type) {
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
				al_save_bitmap("bezier.bmp", image);
				// al_destroy_bitmap(image);
				exit(0);
				break;
			case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
				#ifdef DEBUG
				printf("Mouse button down at (%d, %d)\n", ev.mouse.x, ev.mouse.y);
				#endif
				draw = true;
				if (points.counter >= MAX_POINTS) points.counter = 0;
				points.x[points.counter] = ev.mouse.x;
				points.y[points.counter] = ev.mouse.y;
				points.counter++;
				break;
			default:
				break;
		}

		if (draw) {
			draw = false;
			draw_bezier(image, display, &points);
			al_draw_bitmap(image, 0, 0, 0);
			al_flip_display();
		}

	}
	return 0;
}

void draw_bezier (ALLEGRO_BITMAP *image, ALLEGRO_DISPLAY *display, Points *points) {
	ALLEGRO_LOCKED_REGION *region = NULL;
	unsigned char *data = NULL;

	al_set_target_bitmap(image);
	al_clear_to_color(al_map_rgb(255, 255, 255));
	al_set_target_backbuffer(display);

	region = al_lock_bitmap(image, ALLEGRO_PIXEL_FORMAT_ABGR_8888, ALLEGRO_LOCK_READWRITE);
	if (!region) {
		printf("Error locking bitmap\n");
		exit(-1);
	}

	data = (unsigned char *) region->data;
	// data -= (-region->pitch * (HEIGHT - 1));

	if (points->counter > 0) {
		bezier(data, points->counter, points->x, points->y, region->pitch);
	}

	al_unlock_bitmap(image);
}