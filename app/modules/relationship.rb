module Relationship
  private

  def self.existing(start, outrel)
    # Находим id всех уже существующих отношений заданного типа.
    existing = []
    start.rels(:outgoing, outrel).each do |rel|
      existing << rel.end_node.id
    end
    existing
  end

  def self.has_one(start, outrel, goal_class, goal_id)
    saved, change = false, false

    tx = Neo4j::Transaction.new
      if goal_id == ''
        # Если передан пустой параметр и отношение существует, то оно удаляется.
        if start.rel?(:outgoing, outrel)
          start.rel(:outgoing, outrel).delete
          change = true
        end
      else
        # Ищем ноду.
        goal = Kernel.const_get(goal_class).find(goal_id)
        # Проверяем существует ли уже отношение.
        if start.rel?(:outgoing, outrel)
          # Если существует, то проверяется не тоже самое ли это отношение.
          # Если нет, то удаляем отличающееся старое (очищаем место ибо has_one).
          start.rel(:outgoing, outrel).delete unless start.rel(:outgoing, outrel).end_node == goal
        end
        # Теперь отношение либо отсутствует (было удалено, если устанавливаем новое отношение),
        # либо нужная(!) запись уже существует. Поэтому снова проверяем на существование
        # и пишем новое отношение только при его отсутствии. 
        # Start --:outrel--> Goal.
        if goal && !start.rel?(:outgoing, outrel)
          start.outgoing(outrel) << goal
          change = true
        end
      end
      saved = start.save if change
    tx.success
    tx.finish
    saved
  end

  def self.has_many(start, outrel, goal_class, goal_ids)
    saved, change = false, false

    tx = Neo4j::Transaction.new
      if goal_ids.length > 1
        # Находим id всех уже существующих отношений заданного типа.
        # existing = existing(start, outrel) - работает нестабильно, поэтому дублируем код:
        existing = []
        start.rels(:outgoing, outrel).each do |rel|
          existing << rel.end_node.id
        end
        # Сравниваем поступивший список отношений, которые должны существовать
        # (при этом передается весь список, ненужных нет (снять галочку)),
        # c теми которые уже существуют.
        if goal_ids != existing
          diff = existing - goal_ids
          # Если они отличаются находим те которые физически существуют, но их
          # не должно быть в будущем (сняли галочку), и удаляем эти отношения.
          if diff.any?
            diff.each do |del_id|
              goal = Kernel.const_get(goal_class).find(del_id)
              start.rels(:outgoing, outrel).to_other(goal).first.delete
              change = true
            end
          end
        end
        # Перебираем поступивший список отношений, и если такого отношения еще 
        # не существует, то создаем.
        goal_ids.each do |id|
          # Проверка на "" нужна т.к. первым параметром всегда идет "",
          # для того чтобы можно было передать пустой список (сняты все галочки).
          unless id == ''
            unless existing.include?(id)
              if goal = Kernel.const_get(goal_class).find(id)
                start.outgoing(outrel) << goal
                change = true
              end
            end
          end
        end
      else
        # Удалить все отношения если передан лишь параметр "".
        if start.rels(:outgoing, outrel).any?
          start.rels(:outgoing, outrel).delete_all
          change = true
        end
      end
      saved = start.save if change
    tx.success
    tx.finish
    saved
  end
end