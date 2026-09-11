void main() {
    var monthStart = LocalDate.of(2026, 9, 1);
    IO.println(monthStart + " is a " + monthStart.getDayOfWeek()
             + ", " + monthStart.lengthOfMonth() + " days");
    var pauseFrom = LocalDate.of(2026, 9, 14);
    var pauseTo = LocalDate.of(2026, 9, 20);
    long pausedDays = ChronoUnit.DAYS.between(pauseFrom, pauseTo) + 1;
    IO.println("Paused " + pausedDays + " days, resumes " + pauseTo.plusDays(1));
    int billableDays = monthStart.lengthOfMonth() - (int) pausedDays;
    IO.println("Ravi's bill: " + billableDays * 2 * 120);

    var joined = LocalDate.of(2025, 6, 29);
    var loyalty = Period.between(joined, monthStart);
    IO.println("Customer for " + loyalty.getYears() + "y "
             + loyalty.getMonths() + "m " + loyalty.getDays() + "d");
    IO.println(joined.isBefore(monthStart) + " "
             + joined.plusYears(1).isBefore(monthStart));
    long sundays = monthStart.datesUntil(monthStart.plusMonths(1))
                             .filter(d -> d.getDayOfWeek() == DayOfWeek.SUNDAY).count();
    IO.println("Sundays off: " + sundays);
}
