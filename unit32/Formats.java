void main() {
    var pauseFrom = LocalDate.of(2026, 9, 14);
    var indian = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    IO.println("Pause from " + pauseFrom.format(indian));
    IO.println(LocalDate.parse("21/09/2026", indian));
    IO.println(LocalDate.parse("2026-09-21"));
    IO.println(LocalTime.of(12, 30) + " " + LocalDateTime.of(2026, 9, 14, 12, 30));
}
