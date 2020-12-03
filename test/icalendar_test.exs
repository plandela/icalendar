defmodule ICalendarTest do
  use ExUnit.Case

  @vendor "ICalendar Test"

  test "ICalendar.to_ics/1 of empty calendar" do
    ics = %ICalendar{} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Plandela//Plandela//EN
           END:VCALENDAR
           """
  end

  test "ICalendar.to_ics/1 of empty calendar with custom vendor" do
    ics = %ICalendar{} |> ICalendar.to_ics(vendor: @vendor)

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Plandela//#{@vendor}//EN
           END:VCALENDAR
           """
  end

  test "ICalendar.to_ics/1 of a calendar with an event, as in README" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstamp: ~U[2015-12-10 07:30:00Z],
        dtstart: ~U[2015-12-24 08:30:00Z],
        transp: "TRANSPARENT",
        dtend: ~U[2015-12-24 08:45:00Z],
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: ~U[2015-12-24 19:00:00Z],
        dtend: ~U[2015-12-24 22:30:00Z],
        description: "A big long meeting with lots of details."
      }
    ]

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Plandela//Plandela//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars.
           DTEND:20151224T084500Z
           DTSTAMP:20151210T073000Z
           DTSTART:20151224T083000Z
           SUMMARY:Film with Amy and Adam
           TRANSP:TRANSPARENT
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:A big long meeting with lots of details.
           DTEND:20151224T223000Z
           DTSTART:20151224T190000Z
           SUMMARY:Morning meeting
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "ICalender.to_ics/1 with location and sanitization" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: ~U[2015-12-24 08:30:00Z],
        dtend: ~U[2015-12-24 08:45:00Z],
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada"
      }
    ]

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Plandela//Plandela//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars\\, and have fun.
           DTEND:20151224T084500Z
           DTSTART:20151224T083000Z
           LOCATION:123 Fun Street\\, Toronto ON\\, Canada
           SUMMARY:Film with Amy and Adam
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "ICalender.to_ics/1 with url" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: ~U[2015-12-24 08:30:00Z],
        dtend: ~U[2015-12-24 08:45:00Z],
        description: "Let's go see Star Wars, and have fun.",
        location: "123 Fun Street, Toronto ON, Canada",
        url: "http://example.com"
      }
    ]

    ics = %ICalendar{events: events} |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Plandela//Plandela//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars\\, and have fun.
           DTEND:20151224T084500Z
           DTSTART:20151224T083000Z
           LOCATION:123 Fun Street\\, Toronto ON\\, Canada
           SUMMARY:Film with Amy and Adam
           URL:http://example.com
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "ICalender.to_ics/1 with rrule and exdates" do
    events = [
      %ICalendar.Event{
        rrule: %{
          byday: ["TH", "WE"],
          freq: "WEEKLY",
          bysetpos: [-1],
          interval: -2,
          until: ~U[2020-12-04 04:59:59Z]
        },
        exdates: [
          Calendar.DateTime.shift_zone!(~U[2020-09-16 18:30:00Z], "America/Toronto"),
          Calendar.DateTime.shift_zone!(~U[2020-09-17 18:30:00Z], "America/Toronto")
        ]
      }
    ]

    ics =
      %ICalendar{events: events}
      |> ICalendar.to_ics()

    assert ics == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Plandela//Plandela//EN
           BEGIN:VEVENT
           EXDATE;TZID=America/Toronto:20200916T143000
           EXDATE;TZID=America/Toronto:20200917T143000
           RRULE:FREQ=WEEKLY;BYDAY=TH,WE;BYSETPOS=-1;INTERVAL=-2;UNTIL=20201204T045959
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "encode_to_iodata/2" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: ~U[2015-12-24 08:30:00Z],
        dtend: ~U[2015-12-24 08:45:00Z],
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: ~U[2015-12-24 19:00:00Z],
        dtend: ~U[2015-12-24 22:30:00Z],
        description: "A big long meeting with lots of details."
      }
    ]

    cal = %ICalendar{events: events}

    assert {:ok, ical} = ICalendar.encode_to_iodata(cal, [])

    assert ical == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Plandela//Plandela//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars.
           DTEND:20151224T084500Z
           DTSTART:20151224T083000Z
           SUMMARY:Film with Amy and Adam
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:A big long meeting with lots of details.
           DTEND:20151224T223000Z
           DTSTART:20151224T190000Z
           SUMMARY:Morning meeting
           END:VEVENT
           END:VCALENDAR
           """
  end

  test "encode_to_iodata/1" do
    events = [
      %ICalendar.Event{
        summary: "Film with Amy and Adam",
        dtstart: ~U[2015-12-24 08:30:00Z],
        dtend: ~U[2015-12-24 08:45:00Z],
        description: "Let's go see Star Wars."
      },
      %ICalendar.Event{
        summary: "Morning meeting",
        dtstart: ~U[2015-12-24 19:00:00Z],
        dtend: ~U[2015-12-24 22:30:00Z],
        description: "A big long meeting with lots of details."
      }
    ]

    cal = %ICalendar{events: events}

    assert {:ok, ical} = ICalendar.encode_to_iodata(cal)

    assert ical == """
           BEGIN:VCALENDAR
           CALSCALE:GREGORIAN
           VERSION:2.0
           PRODID:-//Plandela//Plandela//EN
           BEGIN:VEVENT
           DESCRIPTION:Let's go see Star Wars.
           DTEND:20151224T084500Z
           DTSTART:20151224T083000Z
           SUMMARY:Film with Amy and Adam
           END:VEVENT
           BEGIN:VEVENT
           DESCRIPTION:A big long meeting with lots of details.
           DTEND:20151224T223000Z
           DTSTART:20151224T190000Z
           SUMMARY:Morning meeting
           END:VEVENT
           END:VCALENDAR
           """
  end
end
